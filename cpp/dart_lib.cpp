#include "dart_lib.h"
#include "dart_native_api.h"
#include "dart_api_dl.h"
#include <mutex>

std::vector<Dart_Port> s_event_bus_ports;
std::mutex s_event_bus_mutex;

std::atomic<bool> stop_dart = false;

void NotifyDartPort(Dart_Port send_port, DartResult* result);
void NotifyDart(DartResult* result);

void stopDart() {
    stop_dart = true;
}

void register_event_port(Dart_Port send_port) {
    std::lock_guard<std::mutex> lock(s_event_bus_mutex);
    if (std::find(s_event_bus_ports.begin(), s_event_bus_ports.end(), send_port) == s_event_bus_ports.end()) {
        s_event_bus_ports.push_back(send_port);
        std::cout << "C++: Registered event port: " << send_port << ". Total: " << s_event_bus_ports.size() << std::endl;
    }
}

void unregister_event_port(Dart_Port send_port) {
    std::lock_guard<std::mutex> lock(s_event_bus_mutex);
    s_event_bus_ports.erase(std::remove(s_event_bus_ports.begin(), s_event_bus_ports.end(), send_port), s_event_bus_ports.end());
    std::cout << "C++: Unregistered event port: " << send_port << ". Total: " << s_event_bus_ports.size() << std::endl;
}

void sendToDart(google::protobuf::MessageLite* proto, uint32_t taskId) {
    auto res = new DartResult(taskId);
    if(proto != nullptr) {
        auto len = proto->ByteSizeLong();
        res->protoBuf = static_cast<uint8_t*>(malloc(len));
        res->len = (int) len;
        memset(res->protoBuf, 0, len);
        proto->SerializeToArray(res->protoBuf, len);
    }
    NotifyDart(res);
}

void NotifyDart(DartResult* original_result) {
    if(stop_dart) {
        std::cerr << "Dart stop" << std::endl;
        return;
    }
    if (!original_result) {
        std::cerr << "Cannot broadcast null DartResult." << std::endl;
        return;
    }
    // 1. Extract the data from the original DartResult.
    uint64_t taskId = original_result->taskId;
    uint32_t len = original_result->len;
    uint8_t* protoBuf_original_data = original_result->protoBuf; // Pointer to the original data

    // 2. IMPORTANT: Take ownership of the original protoBuf data so original_result's
    //    destructor doesn't try to free it.
    original_result->protoBuf = NULL;

    // 3. Delete the original DartResult wrapper object immediately after extracting data.
    //    The `protoBuf_original_data` is now held by this function's scope.
    delete original_result;

    std::lock_guard<std::mutex> lock(s_event_bus_mutex);

    // OPTIMIZATION: Handle the single-port case without copying the protobuf data
    if (s_event_bus_ports.size() == 1) {
        Dart_Port port = s_event_bus_ports[0]; // Get the single registered port

        // Create a NEW DartResult wrapper for this single port.
        // Directly assign the original protoBuf_original_data.
        // NotifyDartPort will take ownership of this original data.
        DartResult* new_result_for_port = new DartResult(taskId);
        new_result_for_port->len = len;
        new_result_for_port->protoBuf = protoBuf_original_data; // Use the original data

        // Call NotifyDartPort, which will take ownership of new_result_for_port
        // and the original_data it now points to.
        NotifyDartPort(port, new_result_for_port);

        // Since NotifyDartPort took ownership of protoBuf_original_data,
        // we do NOT need to delete[] it here.
        return; // Exit the function after handling the single port
    }

    // Handle multiple ports (the original logic where copying is necessary)
    for (Dart_Port port : s_event_bus_ports) {
        // For each port, create a NEW COPY of the data.
        uint8_t* copied_protoBuf_data = static_cast<uint8_t*>(malloc(len));
        memcpy(copied_protoBuf_data, protoBuf_original_data, len);

        // Create a new DartResult wrapper for this specific port
        DartResult* new_result_for_port = new DartResult(taskId);
        new_result_for_port->len = len;
        new_result_for_port->protoBuf = copied_protoBuf_data;

        // Call NotifyDartPort, which will take ownership of new_result_for_port
        // and its copied_protoBuf_data.
        NotifyDartPort(port, new_result_for_port);
    }
    // After the loop, free the original `protoBuf_original_data` ONLY IF
    // it was copied (i.e., the `if (size() == 1)` block was NOT executed).
    // If the single-port case was hit, NotifyDartPort already took ownership.
    free(protoBuf_original_data);
}

void FreeFinalizer(void* isolate_callback_data, void* peer) {
    free(peer);  // If you used malloc()
}

// Unified NotifyDart for all C++-initiated callbacks (events & request-response)
// 'result' is the DartResult* that 'MakeProto' functions return, containing the pre-serialized data.
void NotifyDartPort(Dart_Port send_port, DartResult* result) {
    if (result == nullptr) {
        std::cerr << "Cannot post null DartResult." << std::endl;
        return;
    }
    if (send_port == 0) {
        std::cerr << "Attempted to post message to a null Dart port." << std::endl;
        delete result; // Delete DartResult if port is invalid (its destructor frees protoBuf)
        return;
    }
    // 1. Create Dart_CObject for the taskId
    Dart_CObject dart_task_id;
    dart_task_id.type = Dart_CObject_kInt64;
    dart_task_id.value.as_int64 = result->taskId;

    // 2. Create Dart_CObject for the serialized protobuf data (Uint8List)
    Dart_CObject dart_byte_array;
    dart_byte_array.type = Dart_CObject_kExternalTypedData;
    dart_byte_array.value.as_external_typed_data.type = Dart_TypedData_kUint8;
    dart_byte_array.value.as_external_typed_data.data = result->protoBuf;
    dart_byte_array.value.as_external_typed_data.length = result->len;
    dart_byte_array.value.as_external_typed_data.peer = result->protoBuf;
    dart_byte_array.value.as_external_typed_data.callback = FreeFinalizer;

    // 3. Create a Dart_CObject array to hold both taskId and data
    Dart_CObject* message_parts[] = {&dart_task_id, &dart_byte_array};
    Dart_CObject full_message;
    full_message.type = Dart_CObject_kArray;
    full_message.value.as_array.length = 2;
    full_message.value.as_array.values = message_parts;

    // 4. Post the message to Dart
    bool success = Dart_PostCObject_DL(send_port, &full_message);
    if (!success) {
    #ifdef NDEBUG
        std::cerr << "C++: Failed to post message to Dart_Port: " << send_port << std::endl;
    #endif
        // If posting failed, Dart didn't take ownership of protoBuf.
        // The DartResult's destructor will correctly free protoBuf here.
        delete result;
    } else {
        // If posting succeeded, Dart took ownership of protoBuf.
        // Nullify the pointer in DartResult to prevent double-free by its destructor.
        result->protoBuf = NULL;
        delete result; // Delete the DartResult object itself
    }
}

// Initialize `dart_api_dl.h`
intptr_t initDartApiDL(void *data) {
    return Dart_InitializeApiDL(data);
}
