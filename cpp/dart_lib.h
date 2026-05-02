#ifndef DART_LIB_H
#define DART_LIB_H

#include <stdbool.h>
#include <stdio.h>
#include <stdint.h>
#include <functional>

#include "protobuf/generated/app.pb.h"
#include "dart_api.h"

#ifdef __cplusplus
extern "C" {
#endif

class DartResult {
public:
    DartResult(uint64_t id) : len(0), protoBuf(NULL), taskId(id) {}
    uint64_t len;
    uint8_t* protoBuf;
    uint64_t taskId;

    ~DartResult() {
        if(protoBuf != nullptr) {
            free(protoBuf);
        }
    }
};

intptr_t initDartApiDL(void* data);
void register_event_port(Dart_Port send_port);
void unregister_event_port(Dart_Port send_port);

void stopDart();
void sendToDart(google::protobuf::MessageLite* proto, uint32_t taskId = 0);

#ifdef __cplusplus
}
#endif

#endif //DART_LIB_H
