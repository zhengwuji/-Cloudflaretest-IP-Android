# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.

# Keep Go mobile classes
-keep class go.** { *; }
-keep class com.cfdata.cfdata.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

