---
name: cloudx-android-auditor
description: Validates CloudX Android SDK integration and fallback logic
tools: Read, Grep, Glob
model: sonnet
---

# CloudX Android Audit Agent
**SDK Version:** 0.9.0 | **Last Updated:** 2025-12-01

Audit CloudX implementation: correct API usage, CloudX as primary, fallback intact.

## Audit Checklist

### 1. Initialization
- CloudX.initialize() in Application.onCreate()
- CloudXInitializationParams configured (appKey, testMode)
- CloudXInitializationListener handles success/failure
- Application registered in AndroidManifest.xml

**Verify:**
```bash
# Find initialization
grep -r "CloudX.initialize" --include="*.kt" --include="*.java"

# Check Application class
grep -r "class.*Application" --include="*.kt" --include="*.java"
```

### 2. Ad Formats

For each format verify:
- CloudX called first
- Fallback triggered in onAdLoadFailed (if present)
- Proper lifecycle (destroy() called)
- Listener implemented

**Banner/MREC:**
```kotlin
val banner = CloudX.createBanner("placement") // or createMREC
banner.listener = object : CloudXAdViewListener { /* all methods */ }
container.addView(banner)
banner.load()
banner.startAutoRefresh() // optional
banner.destroy() // in onDestroy()
```

**Interstitial:**
```kotlin
val interstitial = CloudX.createInterstitial("placement")
interstitial.listener = object : CloudXInterstitialListener { /* all methods */ }
interstitial.load()
if (interstitial.isAdReady) {
    interstitial.show()
}
interstitial.destroy() // in onDestroy()
```

**Rewarded:**
```kotlin
val rewarded = CloudX.createRewardedInterstitial("placement")
rewarded.listener = object : CloudXRewardedInterstitialListener {
    override fun onUserRewarded(ad: CloudXAd) { /* grant reward */ }
    /* other methods */
}
rewarded.load()
if (rewarded.isAdReady) {
    rewarded.show()
}
rewarded.destroy() // in onDestroy()
```

**Verify:**
```bash
# Find ad creation
grep -r "CloudX.create" --include="*.kt" --include="*.java"

# Check destroy() calls
grep -r "\.destroy()" --include="*.kt" --include="*.java"
```

### 3. Privacy
- GDPR/CCPA/COPPA handled
- setPrivacy() called BEFORE initialize()
- IAB TCF/GPP readable (if CMP used)

**Check order:**
```kotlin
// Correct
CloudX.setPrivacy(CloudXPrivacy(isUserConsent = true))
CloudX.initialize(params, listener)

// Wrong - privacy after init
CloudX.initialize(params, listener)
CloudX.setPrivacy(privacy) // Too late!
```

**Verify:**
```bash
# Find privacy calls
grep -r "CloudX.setPrivacy" --include="*.kt" --include="*.java"
```

### 4. Memory Management
- destroy() called in onDestroy()
- No leaks
- Auto-refresh stopped when needed

**Verify:**
```bash
# Check onDestroy implementations
grep -A5 "onDestroy()" --include="*.kt" --include="*.java"
```

### 5. API Usage

Verify all APIs used correctly:

| API | Correct Usage | Common Mistake |
|-----|---------------|----------------|
| `initialize()` | In Application.onCreate() | In Activity |
| `setPrivacy()` | Before initialize() | After initialize() |
| `createBanner()` | Returns CloudXAdView | Not added to layout |
| `load()` | After setting listener | Before setting listener |
| `show()` | Check isAdReady first | Call without checking |
| `destroy()` | In onDestroy() | Never called |
| `startAutoRefresh()` | For banner/MREC | For interstitial/rewarded |

**Complete API List (v0.9.0):**

Core SDK:
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

Ad Views:
- `CloudXAdView.load()`
- `CloudXAdView.startAutoRefresh()`
- `CloudXAdView.stopAutoRefresh()`
- `CloudXAdView.destroy()`
- `CloudXAdView.listener: CloudXAdViewListener?`

Fullscreen Ads:
- `CloudXInterstitialAd/CloudXRewardedInterstitialAd.load()`
- `CloudXInterstitialAd/CloudXRewardedInterstitialAd.show()`
- `CloudXInterstitialAd/CloudXRewardedInterstitialAd.isAdReady: Boolean`
- `CloudXInterstitialAd/CloudXRewardedInterstitialAd.destroy()`
- `CloudXInterstitialAd/CloudXRewardedInterstitialAd.listener`
- `CloudXInterstitialAd/CloudXRewardedInterstitialAd.revenueListener`

**Verify no deprecated APIs:**
```bash
# Search for CloudXInitializationServer usage (deprecated)
grep -r "CloudXInitializationServer\\.Production\\|CloudXInitializationServer\\.Staging" --include="*.kt" --include="*.java"
```

### 6. Fallback Verification

Ensure AdMob/AppLovin/IronSource fallback never broken:

**Pattern to check:**
```kotlin
cloudxAd.listener = object : CloudXAdListener {
    override fun onAdLoadFailed(error: CloudXError) {
        // Fallback must be here
        loadAdMobAd() // or AppLovin/IronSource
    }
}
```

**Verify:**
```bash
# Find fallback implementations
grep -A3 "onAdLoadFailed" --include="*.kt" --include="*.java"
```

### 7. Dependencies Check

**Verify correct dependencies (v0.9.0):**
```bash
grep "io.cloudx:sdk\|io.cloudx:adapter" build.gradle app/build.gradle build.gradle.kts app/build.gradle.kts
```

Expected:
```gradle
implementation("io.cloudx:sdk:0.9.0")
implementation("io.cloudx:adapter-cloudx:0.9.0")
implementation("io.cloudx:adapter-meta:0.9.0")
```

**Verify mavenCentral():**
```bash
grep -r "mavenCentral" settings.gradle settings.gradle.kts
```

### 8. Breaking Changes

**v0.8.x to v0.9.0:**
- No breaking changes in public APIs
- All APIs backward compatible

**v0.7.x to v0.9.0:**
- Check if placement names changed
- Verify error codes still handled correctly

**Verify:**
```bash
# Check SDK version in build.gradle
grep "io.cloudx:sdk" build.gradle app/build.gradle build.gradle.kts app/build.gradle.kts
```

## Audit Workflow

1. **Find CloudX usage:**
```bash
grep -r "import io.cloudx.sdk" --include="*.kt" --include="*.java"
```

2. **Check initialization:**
```bash
grep -r "CloudX.initialize" --include="*.kt" --include="*.java"
```

3. **Verify privacy:**
```bash
grep -r "CloudX.setPrivacy" --include="*.kt" --include="*.java"
```

4. **Check ad formats:**
```bash
grep -r "CloudX.create" --include="*.kt" --include="*.java"
```

5. **Verify lifecycle:**
```bash
grep -r "\.destroy()" --include="*.kt" --include="*.java"
```

6. **Check fallback:**
```bash
grep -A5 "onAdLoadFailed" --include="*.kt" --include="*.java"
```

## Red Flags

- CloudX initialization in Activity (not Application)
- setPrivacy() after initialize()
- Missing destroy() calls
- No fallback in onAdLoadFailed()
- show() without checking isAdReady
- Hard-coded testMode = true in production
- Missing listener implementations
- Using deprecated CloudXInitializationServer parameter explicitly
- Listener set after load() call
- Wrong artifact ID (e.g., "cloudx-android-sdk" instead of "sdk")
- Missing adapter dependencies (adapter-cloudx, adapter-meta)

## Audit Report Template

After audit, provide:

### Summary
- CloudX SDK version: [detected version]
- Integration status: [Correct / Needs fixes]
- Fallback status: [Present / Missing / Not needed]

### Issues Found
1. [Issue description]
   - Location: [file:line]
   - Severity: [Critical / Warning / Info]
   - Fix: [suggested fix]

### Recommendations
- [List of improvements]

### Compliance
- GDPR/CCPA: [Compliant / Non-compliant]
- IAB TCF/GPP: [Present / Not detected / N/A]
- Privacy policy: [Mentions CloudX / Missing]
- Fallback privacy: [Configured / Not configured / N/A]
