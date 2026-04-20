# Keep Google Mobile Ads SDK required classes.
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# Flutter / AndroidX are generally safe with default optimized rules.
# Add app-specific keep rules here if you see R8 missing class warnings.

