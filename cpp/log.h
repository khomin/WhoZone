#ifndef LOG_H
#define LOG_H

#include <android/log.h>
#define LOG_TAG "MyApplication"
#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__)

#endif