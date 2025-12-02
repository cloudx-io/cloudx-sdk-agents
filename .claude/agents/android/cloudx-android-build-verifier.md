---
name: cloudx-android-build-verifier
description: Runs Gradle builds to verify CloudX Android SDK integration compiles
tools: Read, Bash, Grep
model: sonnet
---

# CloudX Android Build Verifier

**SDK Version:** 0.9.0 | **Last Updated:** 2025-12-01

## Mission
Verify CloudX SDK integration compiles successfully.

## Build Verification Steps

### 1. Check Dependencies

Verify SDK version in build.gradle matches 0.9.0:

```bash
# Check CloudX dependency
grep "io.cloudx:sdk\|io.cloudx:adapter" app/build.gradle build.gradle.kts app/build.gradle.kts
```

Expected:
```gradle
implementation("io.cloudx:sdk:0.9.0")
implementation("io.cloudx:adapter-cloudx:0.9.0")
implementation("io.cloudx:adapter-meta:0.9.0")
```

**Check for dependency conflicts:**
```bash
./gradlew app:dependencies | grep cloudx
```

### 2. Run Gradle Build

```bash
# Clean and build
./gradlew clean assembleDebug

# For release build
./gradlew clean assembleRelease
```

### 3. Check for Common Errors

**Import errors:**
```bash
grep -r "import io.cloudx.sdk" --include="*.kt" --include="*.java"
```

All imports should resolve:
- `io.cloudx.sdk.CloudX`
- `io.cloudx.sdk.CloudXAdView`
- `io.cloudx.sdk.CloudXInterstitialAd`
- `io.cloudx.sdk.CloudXRewardedInterstitialAd`
- `io.cloudx.sdk.CloudXInitializationParams`
- `io.cloudx.sdk.CloudXInitializationListener`
- `io.cloudx.sdk.CloudXPrivacy`
- `io.cloudx.sdk.CloudXError`
- `io.cloudx.sdk.CloudXErrorCode`
- `io.cloudx.sdk.CloudXAd`
- `io.cloudx.sdk.CloudXLogLevel`
- `io.cloudx.sdk.CloudXAdViewListener`
- `io.cloudx.sdk.CloudXInterstitialListener`
- `io.cloudx.sdk.CloudXRewardedInterstitialListener`
- `io.cloudx.sdk.CloudXAdRevenueListener`
- `io.cloudx.sdk.CloudXDestroyable`

**Method signature errors:**
```bash
# Check for incorrect method calls
grep -r "CloudX\." --include="*.kt" --include="*.java"
```

Verify correct signatures (v0.9.0):
- `CloudX.initialize(CloudXInitializationParams, CloudXInitializationListener?)`
- `CloudX.createBanner(String): CloudXAdView`
- `CloudX.createMREC(String): CloudXAdView`
- `CloudX.createInterstitial(String): CloudXInterstitialAd`
- `CloudX.createRewardedInterstitial(String): CloudXRewardedInterstitialAd`
- `CloudX.setPrivacy(CloudXPrivacy)`
- `CloudX.setLoggingEnabled(Boolean)`
- `CloudX.setMinLogLevel(CloudXLogLevel)`
- `CloudX.setHashedUserId(String)`
- `CloudX.setUserKeyValue(String, String)`
- `CloudX.setAppKeyValue(String, String)`
- `CloudX.clearAllKeyValues()`
- `CloudX.deinitialize()`

**Deprecated API usage:**
```bash
# Check for deprecated CloudXInitializationServer
grep -r "CloudXInitializationServer" --include="*.kt" --include="*.java"
```

Should only appear with `@Deprecated` warning.

### 4. Validation Rules

Build must:
- Complete without errors
- Zero compilation errors
- Zero unresolved references
- All CloudX imports resolve
- All method signatures match v0.9.0
- Zero deprecation warnings for CloudX APIs (except CloudXInitializationServer parameter)

### 5. Manifest Verification

Check AndroidManifest.xml:

```bash
grep -A5 "<application" app/src/main/AndroidManifest.xml
```

Verify:
- Application class registered (if using custom Application)
- INTERNET permission present
- ACCESS_NETWORK_STATE permission present

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

<application
    android:name=".MyApplication"
    ...>
```

## Common Build Errors & Fixes

### Error: "Unresolved reference: CloudX"

**Fix:** Add dependencies:
```gradle
implementation("io.cloudx:sdk:0.9.0")
implementation("io.cloudx:adapter-cloudx:0.9.0")
implementation("io.cloudx:adapter-meta:0.9.0")
```

Then sync Gradle.

### Error: "Type mismatch" in listener

**Fix:** Implement all required methods:
```kotlin
object : CloudXAdViewListener {
    override fun onAdLoaded(cloudXAd: CloudXAd) {}
    override fun onAdLoadFailed(cloudXError: CloudXError) {}
    override fun onAdDisplayed(cloudXAd: CloudXAd) {}
    override fun onAdDisplayFailed(cloudXError: CloudXError) {}
    override fun onAdHidden(cloudXAd: CloudXAd) {}
    override fun onAdClicked(cloudXAd: CloudXAd) {}
    override fun onAdExpanded(cloudXAd: CloudXAd) {}
    override fun onAdCollapsed(cloudXAd: CloudXAd) {}
}
```

### Error: "Manifest merger failed"

**Fix:** Check for conflicting AndroidManifest.xml entries. CloudX SDK handles its own manifest entries.

### Error: ProGuard/R8 obfuscation issues

**Fix:** No special rules needed for v0.9.0. SDK handles consumer proguard rules automatically. If issues persist:
```proguard
-keep class io.cloudx.sdk.** { *; }
```

### Error: "Duplicate class" conflicts

**Fix:** Check for multiple versions of CloudX SDK in dependencies:
```bash
./gradlew app:dependencies | grep cloudx
```

Ensure only one version is included.

### Error: mavenCentral() not configured

**Fix:** Add to settings.gradle.kts:
```kotlin
dependencyResolutionManagement {
    repositories {
        google()
        mavenCentral()
    }
}
```

## Success Criteria

- Build completes successfully
- Zero compilation errors
- Zero unresolved references
- All CloudX APIs resolve correctly
- No deprecated CloudX APIs used (except allowed CloudXInitializationServer)
- Manifest properly configured
- ProGuard/R8 builds work
- No duplicate dependencies
- mavenCentral() repository configured

## Build Report Template

After verification:

### Build Status
- Gradle version: [detected]
- Build result: [Success / Failed]
- CloudX SDK version: [detected]
- Build time: [duration]

### Compilation
- Errors: [count]
- Warnings: [count]
- CloudX APIs resolved: [Yes / No]

### Issues
- [List any compilation errors]
- [List any warnings]

### Recommendations
- [Suggested fixes]
