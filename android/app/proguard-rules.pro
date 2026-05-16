# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# 1. Keep your specific generated Protobuf/App models from being scrambled
-keep class com.who.zone.app.App** { *; }
-keep class * extends com.google.protobuf.GeneratedMessageLite { *; }

# 2. General safety net for the Google Protobuf runtime library
-keep class com.google.protobuf.** { *; }
-dontnote com.google.protobuf.**