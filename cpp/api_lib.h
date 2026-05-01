#ifndef API_LIB_H
#define API_LIB_H

#include <stdbool.h>
#include <stdio.h>
#include <stdint.h>
#include <functional>

#include "dart_api.h"
#include "dart_native_api.h"
#include "dart_api_dl.h"

#ifdef __cplusplus
extern "C" {
#endif

class DartResult {
public:
    DartResult(uint32_t id) : len(0), protobuf(NULL), taskId(id) {}
    uint32_t len;
    uint8_t* protobuf;
    uint32_t taskId;
};
typedef void (*OnEventCbTypedef)(DartResult* data);
typedef std::function<void()> Work;

void onEventCb(Dart_Port send_port, OnEventCbTypedef cb);

void init(uint32_t taskId, uint8_t *data, uint32_t len);
void testMethod(uint32_t taskId);
void destroyAll();

DART_EXPORT void dartExecuteCallback(Work* work_ptr);
DART_EXPORT intptr_t initDartApiDL(void* data);

void DartCallResult(DartResult *data);

static const char *TAG = "Api";

#ifdef __cplusplus
} // extern "C"
#endif

#endif //API_LIB_H
