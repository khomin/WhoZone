#include <queue>
#include <thread>

#include "api_lib.h"
#include "dart_api.h"
#include "BS_thread_pool.hpp"
#include <app.pb.h>

OnEventCbTypedef eventCb;
BS::thread_pool* threadPool = nullptr;
// std::shared_ptr<MiscDb> db;
std::mutex threadLock;
Dart_Port eventCbSend_port;

void onEventCb(Dart_Port send_port, OnEventCbTypedef cb) {
    eventCb = cb;
    eventCbSend_port = send_port;
}

void init(uint32_t taskId, uint8_t *data, uint32_t len) {
    GOOGLE_PROTOBUF_VERIFY_VERSION;
    std::lock_guard<std::mutex> lk(threadLock);
    // api::InitParams initParams;
    // initParams.ParseFromArray(data, (int) len);
    if(threadPool == nullptr) {
        threadPool = new BS::thread_pool(1);
    }
    // db = std::make_shared<MiscDb>(initParams.local_dir());
}

void destroyAll() {
    if(threadPool != nullptr) {
        threadPool->purge();
        threadPool->wait_for_tasks();
        delete threadPool;
        threadPool = nullptr;
    }
}

void testMethod(uint32_t taskId) {
    LOG_F(INFO, "%s: %s", TAG, "test method 🔥🔥🔥");
}

void DartCallResult(DartResult *data) {
    auto callback = eventCb;
    const Work work = [data, callback]() {
        callback(data);
        delete[] (uint8_t *) data->protoBuf;
        delete data;
    };
    const Work *work_ptr = new Work(work);
    NotifyDart(eventCbSend_port, work_ptr);
}

// notify dart through a port that the C lib has pending async callbacks
void NotifyDart(Dart_Port send_port, const Work* work) {
  const auto work_addr = reinterpret_cast<intptr_t>(work);
  Dart_CObject dart_object;
  dart_object.type = Dart_CObject_kInt64;
  dart_object.value.as_int64 = work_addr;

  const bool result = Dart_PostCObject_DL(send_port, &dart_object);
  if (!result) {
      LOG_F(INFO, "%s: %s", TAG, "Posting message to port failed");
  }
}

DART_EXPORT intptr_t initDartApiDL(void* data) {
  return Dart_InitializeApiDL(data);
}

DART_EXPORT void dartExecuteCallback(Work* work_ptr) {
  const Work work = *work_ptr;
  work();
  delete work_ptr;
}