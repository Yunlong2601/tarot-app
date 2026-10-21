# Keep rules for the release build (R8). Add a rule only when a release build
# crashes or fails on a missing class; test the release build on a real phone.

# tflite_flutter / TensorFlow Lite: the GPU delegate classes are optional.
-keep class org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.lite.gpu.**
