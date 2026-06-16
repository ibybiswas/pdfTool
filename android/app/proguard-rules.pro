# This is a configuration file for ProGuard.
# http://proguard.sourceforge.net/index.html#manual/usage.html

# Add any project specific keep options here:

# WebView
-keepclassmembers class fqcn.of.javascript.interface.for.webview {
   public *;
}

# If your project uses WebView with JS, uncomment the following and specify the fully qualified
# class name to the JavaScript interface class:
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# AndroidX
-keep class androidx.** { *; }
-dontwarn androidx.**

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }
-dontwarn kotlin.**
-dontwarn kotlinx.**

# Keep our own classes
-keep class com.pdfchef.app.** { *; }

# Preserve line numbers for debugging
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
