# uCrop (image_cropper) optionally references OkHttp to download remote images.
# Those classes are not on the classpath; R8 should not fail the release build.
-dontwarn okhttp3.**
