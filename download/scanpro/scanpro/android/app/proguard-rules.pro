# ============================================================================
# ScanPro - ProGuard Rules
# Professional Document Scanning Application
# ============================================================================

# ============================================================================
# General Flutter Rules
# ============================================================================

# Keep Flutter engine classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.**

# ============================================================================
# Google ML Kit Rules
# ============================================================================

# ML Kit Text Recognition
-keep class com.google.mlkit.vision.text.** { *; }
-keep class com.google.android.gms.internal.** { *; }
-dontwarn com.google.mlkit.vision.text.**

# ML Kit Language ID
-keep class com.google.mlkit.nl.languageid.** { *; }
-dontwarn com.google.mlkit.nl.languageid.**

# ML Kit Translation
-keep class com.google.mlkit.nl.translate.** { *; }
-dontwarn com.google.mlkit.nl.translate.**

# ML Kit Barcode Scanning
-keep class com.google.mlkit.vision.barcode.** { *; }
-dontwarn com.google.mlkit.vision.barcode.**

# ML Kit Common
-keep class com.google.mlkit.common.** { *; }
-keep class com.google.android.libraries.dlx.** { *; }
-keep class com.google.android.odml.** { *; }
-keep class com.google.android.gms.internal.** { *; }
-dontwarn com.google.mlkit.common.**

# Keep ML Kit model data classes
-keepclassmembers class com.google.mlkit.** {
    *;
}

# ============================================================================
# Firebase Rules
# ============================================================================

# Firebase Core
-keep class com.google.firebase.** { *; }
-keep interface com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Firebase Auth
-keep class com.google.firebase.auth.** { *; }
-keepclassmembers class com.google.firebase.auth.** {
    *;
}
-dontwarn com.google.firebase.auth.**

# Firestore
-keep class com.google.firebase.firestore.** { *; }
-keepclassmembers class com.google.firebase.firestore.** {
    *;
}
-keepnames class com.google.firebase.firestore.model.Values { *; }
-dontwarn com.google.firebase.firestore.**

# Firebase Storage
-keep class com.google.firebase.storage.** { *; }
-dontwarn com.google.firebase.storage.**

# Firebase Crashlytics
-keep class com.google.firebase.crashlytics.** { *; }
-dontwarn com.google.firebase.crashlytics.**
-keepattributes SourceFile,LineNumberTable
-keepattributes *Annotation*

# Firebase Analytics
-keep class com.google.firebase.analytics.** { *; }
-dontwarn com.google.firebase.analytics.**

# Firebase Messaging
-keep class com.google.firebase.messaging.** { *; }
-dontwarn com.google.firebase.messaging.**

# Google Play Services
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# ============================================================================
# Syncfusion PDF Rules
# ============================================================================

# Syncfusion PDF
-keep class com.syncfusion.** { *; }
-keepclassmembers class com.syncfusion.** {
    *;
}
-dontwarn com.syncfusion.**

# Keep Syncfusion internal classes
-keep class com.syncfusion.pdf.** { *; }
-keep class com.syncfusion.pdfviewer.** { *; }
-keepnames class com.syncfusion.** { *; }

# ============================================================================
# OpenCV Rules
# ============================================================================

# OpenCV native methods
-keep class org.opencv.** { *; }
-keepclassmembers class org.opencv.** {
    *;
}
-keep class org.opencv.engine.** { *; }
-keepclassmembers class org.opencv.engine.OpenCVEngineInterface {
    *;
}
-dontwarn org.opencv.**

# Keep OpenCV native library loading
-keep class org.opencv.android.** { *; }
-keep class org.opencv.core.** { *; }
-keep class org.opencv.imgproc.** { *; }
-keep class org.opencv.imgcodecs.** { *; }
-keep class org.opencv.utils.** { *; }

# ============================================================================
# Hive Database Rules
# ============================================================================

# Hive adapters and type adapters
-keep class * extends com.hivedb.hive.Adapter { *; }
-keep class * implements com.hivedb.hive.TypeAdapter { *; }
-keepclassmembers class * extends com.hivedb.hive.Adapter {
    <init>(...);
}
-keepclassmembers class * implements com.hivedb.hive.TypeAdapter {
    <init>(...);
}

# Hive generated adapters
-keep class **.hive_adapter.** { *; }
-keepclassmembers class **.hive_adapter.** {
    *;
}

# Keep all Hive annotated classes
-keep @interface com.hivedb.hive.HiveType { *; }
-keep @com.hivedb.hive.HiveType class * { *; }
-keepclassmembers class @com.hivedb.hive.HiveType * { *; }

# Keep Hive box data models
-keep class com.scanpro.app.data.models.** { *; }
-keepclassmembers class com.scanpro.app.data.models.** {
    *;
}

# ============================================================================
# Model Classes - Keep All Data Models
# ============================================================================

# Keep all model classes with their fields for serialization
-keep class com.scanpro.app.data.models.** {
    <fields>;
    <init>(...);
}
-keepclassmembers class com.scanpro.app.data.models.** {
    <fields>;
}

# Keep all entity/document models
-keep class com.scanpro.app.models.** { *; }
-keepclassmembers class com.scanpro.app.models.** {
    *;
}

# ============================================================================
# Google Generative AI (Gemini) Rules
# ============================================================================

# Gemini API models
-keep class com.google.ai.generativelanguage.** { *; }
-keepclassmembers class com.google.ai.generativelanguage.** {
    *;
}
-dontwarn com.google.ai.generativelanguage.**

# Keep JSON serialization for Gemini request/response models
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
-keep class com.google.gson.** { *; }
-keep class com.google.ai.** { *; }
-dontwarn com.google.ai.**

# Keep Gemini API data classes used for serialization
-keep class * implements com.google.ai.generativelanguage.v1.** { *; }
-keepnames class * implements com.google.ai.generativelanguage.v1.**

# ============================================================================
# Camera Rules
# ============================================================================

-keep class androidx.camera.** { *; }
-dontwarn androidx.camera.**

# ============================================================================
# Biometric / Local Auth Rules
# ============================================================================

-keep class androidx.biometric.** { *; }
-dontwarn androidx.biometric.**

# ============================================================================
# Encryption / Security Rules
# ============================================================================

-keep class javax.crypto.** { *; }
-keep class java.security.** { *; }
-dontwarn javax.crypto.**
-dontwarn java.security.**

# Keep encrypt package classes
-keep class org.pointyware.** { *; }
-dontwarn org.pointyware.**

# ============================================================================
# Kotlin Coroutines Rules
# ============================================================================

-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}
-keepclassmembers class kotlinx.coroutines.** {
    volatile <fields>;
}
-dontwarn kotlinx.coroutines.**

# ============================================================================
# Retrofit / OkHttp (if used by Firebase or ML Kit)
# ============================================================================

-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep class okio.** { *; }

# ============================================================================
# Gson Rules (used by various dependencies)
# ============================================================================

-keepattributes Signature
-keepattributes *Annotation*

# Gson specific classes
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }

# Application data classes that are serialized/deserialized over Gson
-keep class com.scanpro.app.data.** { *; }
-keep class com.scanpro.app.models.** { *; }

# Prevent R8 from stripping interface information from TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# ============================================================================
# AndroidX / Jetpack Rules
# ============================================================================

-keep class androidx.** { *; }
-keep interface androidx.** { *; }
-dontwarn androidx.**

# ============================================================================
# WorkManager Rules
# ============================================================================

-keep class androidx.work.** { *; }
-dontwarn androidx.work.**

# ============================================================================
# Riverpod / Freezed / JSON Serializable Generated Code
# ============================================================================

# Keep freezed generated classes
-keep class **.freezed.** { *; }
-keepclassmembers class **.freezed.** { *; }

# Keep JSON serializable generated classes
-keep class **.g.dart.** { *; }
-keepclassmembers class **.g.dart.** { *; }

# Keep Riverpod generated providers
-keep class **.provider.** { *; }
-keepclassmembers class **.provider.** { *; }

# ============================================================================
# General Keep Rules
# ============================================================================

# Keep all classes with native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep custom views
-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet);
}

-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet, int);
}

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Parcelable
-keepclassmembers class * implements android.os.Parcelable {
    public static final ** CREATOR;
}

# Keep Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep R classes
-keepclassmembers class **.R$* {
    public static <fields>;
}

# ============================================================================
# Warning Suppressions
# ============================================================================

-dontwarn java.lang.invoke.StringConcatFactory
-dontwarn java.lang.invoke.CallSite
-dontwarn java.lang.invoke.MethodHandle
-dontwarn java.lang.invoke.MethodHandles$Lookup
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**
