#ifndef API_LIB_H
#define API_LIB_H

#include <functional>

#ifdef __cplusplus
extern "C" {
#endif

void initApi(uint32_t taskId);
void testMethod(uint32_t taskId);
void destroyAll();


#ifdef __cplusplus
} // extern "C"
#endif

static const char *TAG = "Api";

#endif //API_LIB_H
