#include "api_lib.h"
#include "BS_thread_pool.hpp"
#include "app.pb.h"
#include "dart_lib.h"

#include <queue>
#include <thread>

BS::thread_pool threadPool(1);
std::mutex threadLock;

void initApi(uint32_t taskId) {
    GOOGLE_PROTOBUF_VERIFY_VERSION;
    std::lock_guard<std::mutex> lk(threadLock);
    sendToDart(nullptr, taskId);
}

void destroyAll() {
    threadPool.purge();
    threadPool.wait();
}

void testMethod(uint32_t taskId) {
    std::cout << "test method 🔥🔥🔥" << std::endl;
}