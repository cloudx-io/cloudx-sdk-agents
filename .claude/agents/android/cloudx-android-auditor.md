---
name: cloudx-android-auditor
description: Validates CloudX Android SDK integration and fallback logic
tools: Read, Grep, Glob
model: sonnet
---

# CloudX Android Audit Agent
**SDK Version:** 2.0.0 | **Last Updated:** 2026-02-04

Audit CloudX implementation: correct API usage, CloudX as primary, fallback intact.

## Audit Checklist

### 1. Initialization
- CloudX.initialize() in Application.onCreate()
- CloudXInitializationConfiguration builder pattern used
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
val banner = CloudX.createBanner("ad-unit-id") // or createMREC
banner.listener = object : CloudXAdViewListener { /* all methods */ }
container.addView(banner)
// Auto-loads and auto-refreshes - no need to call load()
banner.destroy() // in onDestroy()
```

**Interstitial:**
```kotlin
val interstitial = CloudX.createInterstitial("ad-unit-id")
interstitial.listener = object : CloudXInterstitialListener { /* all methods */ }
interstitial.load()
if (interstitial.isAdReady) {
    interstitial.show(activity)  // Pass Activity
}
interstitial.destroy() // in onDestroy()
```

**Rewarded:**
```kotlin
val rewarded = CloudX.createRewarded("ad-unit-id")
rewarded.listener = object : CloudXRewardedListener {
    override fun onUserRewarded(ad: CloudXAd, reward: CloudXReward) { /* grant reward */ }
    /* other methods */
}
rewarded.load()
if (rewarded.isAdReady) {
    rewarded.show(activity)  // Pass Activity
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
- GDPR/CCPA handled automatically via IAB strings
- CMP writes consent to SharedPreferences
- IAB TCF/GPP readable (if CMP used)

**CloudX automatically reads IAB strings:**
```kotlin
// SDK auto-reads these keys from SharedPreferences:
// - IABTCF_TCString, IABTCF_gdprApplies (TCF v2)
// - IABUSPrivacy_String (CCPA legacy)
// - IABGPP_HDR_GppString, IABGPP_GppSID (GPP modern)
// No manual privacy calls needed

// For GDPR (EU): SDK checks TCF v2 consent for purposes 1-4
// and vendor consent (CloudX Vendor ID: 1510)
```

**Verify CMP integration:**
```bash
# Check for CMP usage
grep -r "IABTCF\|IABGPP\|IABUSPrivacy" --include="*.kt" --include="*.java"
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
| `initialize()` | In Application.onCreate() with builder | In Activity |
| `createBanner()` | Returns CloudXAdView | Not added to layout |
| `show()` | Pass Activity, check isAdReady first | Call without Activity or checking |
| `destroy()` | In onDestroy() | Never called |
| `startAutoRefresh()` | For banner/MREC (optional) | For interstitial/rewarded |
| `setMinLogLevel()` | Use CloudXLogLevel.NONE to disable | Using deprecated setLoggingEnabled() |
| `createBanner()` | Use ad unit ID | Using placement name |

**Complete API List (v2.0.0):**

Core SDK:
- `CloudX.initialize(CloudXInitializationConfiguration, CloudXInitializationListener?)`
- `CloudX.createBanner(String adUnitId): CloudXAdView`
- `CloudX.createMREC(String adUnitId): CloudXAdView`
- `CloudX.createInterstitial(String adUnitId): CloudXInterstitialAd`
- `CloudX.createRewarded(String adUnitId): CloudXRewardedAd`
- `CloudX.setMinLogLevel(CloudXLogLevel)`
- `CloudX.setHashedUserId(String)`
- `CloudX.setUserKeyValue(String, String)`
- `CloudX.setAppKeyValue(String, String)`
- `CloudX.clearAllKeyValues()`

Ad Views:
- `CloudXAdView.setPlacement(String)`
- `CloudXAdView.setCustomData(String)`
- `CloudXAdView.startAutoRefresh()`
- `CloudXAdView.stopAutoRefresh()`
- `CloudXAdView.destroy()`
- `CloudXAdView.listener: CloudXAdViewListener?`
- `CloudXAdView.revenueListener: CloudXAdRevenueListener?`

Fullscreen Ads:
- `CloudXInterstitialAd/CloudXRewardedAd.load()`
- `CloudXInterstitialAd/CloudXRewardedAd.show(Activity)`
- `CloudXInterstitialAd/CloudXRewardedAd.show(Activity, String placement)`
- `CloudXInterstitialAd/CloudXRewardedAd.show(Activity, String placement, String customData)`
- `CloudXInterstitialAd/CloudXRewardedAd.isAdReady: Boolean`
- `CloudXInterstitialAd/CloudXRewardedAd.destroy()`
- `CloudXInterstitialAd/CloudXRewardedAd.listener`
- `CloudXInterstitialAd/CloudXRewardedAd.revenueListener`

**Verify no deprecated APIs:**
```bash
# Search for deprecated APIs (removed in v0.12.0+)
grep -r "CloudXPrivacy\\|setPrivacy\\|effectiveMessage\\|setLoggingEnabled" --include="*.kt" --include="*.java"

# Search for old initialization pattern
grep -r "CloudXInitializationParams\\|CloudXInitializationServer" --include="*.kt" --include="*.java"

# Search for old rewarded API
grep -r "createRewardedInterstitial\\|CloudXRewardedInterstitialAd\\|CloudXRewardedInterstitialListener" --include="*.kt" --include="*.java"
```

### 6. Fallback Verification

Ensure AdMob/AppLovin/IronSource fallback never broken:

**Pattern to check:**
```kotlin
cloudxAd.listener = object : CloudXAdListener {
    override fun onAdLoadFailed(adUnitId: String, error: CloudXError) {
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

**Verify correct dependencies (v2.0.0):**
```bash
grep "io.cloudx:sdk\|io.cloudx:adapter" build.gradle app/build.gradle build.gradle.kts app/build.gradle.kts
```

Expected (core SDK required):
```gradle
implementation("io.cloudx:sdk:2.0.0")
```

Optional adapters (recommended):
```gradle
implementation("io.cloudx:adapter-cloudx:2.0.0")
implementation("io.cloudx:adapter-meta:2.0.0")       // Meta Audience Network 6.21.0
implementation("io.cloudx:adapter-vungle:2.0.0")     // Vungle SDK 7.6.1
implementation("io.cloudx:adapter-inmobi:2.0.0")     // InMobi SDK 11.1.0
```

**Verify mavenCentral():**
```bash
grep -r "mavenCentral" settings.gradle settings.gradle.kts
```

### 8. Breaking Changes

**v0.12.x to v2.0.0:**
- Ad unit IDs replace placement names in all `create*()` methods
- `CloudXInitializationConfiguration.builder()` replaces `CloudXInitializationParams`
- `CloudXRewardedAd` replaces `CloudXRewardedInterstitialAd`
- `CloudXRewardedListener` replaces `CloudXRewardedInterstitialListener`
- `show()` requires `Activity` parameter for fullscreen ads
- Listener callbacks now include `adUnitId` parameter in `onAdLoadFailed()`
- `onUserRewarded()` now includes `CloudXReward` parameter
- `CloudXAd.networkName` replaces `bidderName`
- `CloudXAd.adUnitId` replaces `placementId`
- TCF purposes 1-4 required (was 1-2)
- Banner/MREC auto-load on creation (no need to call `load()`)

**v0.11.x to v2.0.0:**
- All above changes, plus:
- Removed `CloudXError.effectiveMessage` - use `message` directly
- Removed `setLoggingEnabled()` - use `setMinLogLevel(CloudXLogLevel.NONE)`
- Removed `CloudXPrivacy` class - privacy handled automatically via GPP/TCF

**Verify migration:**
```bash
# Check for old APIs
grep -r "CloudXInitializationParams\\|createRewardedInterstitial\\|CloudXRewardedInterstitialAd\\|effectiveMessage\\|setLoggingEnabled\\|CloudXPrivacy" --include="*.kt" --include="*.java"

# Check SDK version
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

3. **Check ad formats:**
```bash
grep -r "CloudX.create" --include="*.kt" --include="*.java"
```

4. **Verify lifecycle:**
```bash
grep -r "\.destroy()" --include="*.kt" --include="*.java"
```

5. **Check fallback:**
```bash
grep -A5 "onAdLoadFailed" --include="*.kt" --include="*.java"
```

## Red Flags

- CloudX initialization in Activity (not Application)
- Using old initialization pattern (`CloudXInitializationParams`)
- Using placement names instead of ad unit IDs
- Using old rewarded API (`createRewardedInterstitial`)
- `show()` without Activity parameter
- `show()` without checking isAdReady
- Using removed APIs (CloudXPrivacy, setPrivacy(), effectiveMessage, setLoggingEnabled())
- Missing destroy() calls
- No fallback in onAdLoadFailed()
- Hard-coded test mode in production
- Missing listener implementations
- Listener set after load() call for fullscreen ads
- Wrong artifact ID (e.g., "cloudx-android-sdk" instead of "sdk")
- Missing recommended adapter dependencies (especially adapter-inmobi)

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
