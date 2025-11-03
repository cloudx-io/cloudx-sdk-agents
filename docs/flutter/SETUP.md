# CloudX Flutter SDK Integration with AI Agents - Setup Guide

**Reduce integration time from 4-6 hours to ~20 minutes**

This guide will walk you through installing and using CloudX Flutter agents to automatically integrate CloudX SDK into your Flutter app with optional fallback to AdMob or AppLovin.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [What You'll Need](#what-youll-need)
3. [Installation](#installation)
4. [Quick Start (5 Minutes)](#quick-start-5-minutes)
5. [Integration Modes](#integration-modes)
6. [Agent Overview](#agent-overview)
7. [Usage Examples](#usage-examples)
8. [Testing Your Integration](#testing-your-integration)
9. [Troubleshooting](#troubleshooting)
10. [Next Steps](#next-steps)

---

## Prerequisites

### Required Software

- **Flutter SDK**: 3.0.0 or higher
- **Dart SDK**: 3.0.0 or higher
- **Claude Code**: Installed and configured
- **Git**: For version control (recommended)

**Check your Flutter/Dart versions**:
```bash
flutter --version
dart --version
```

**Update if needed**:
```bash
flutter upgrade
```

### Platform Requirements

**Android**:
- Minimum SDK: API 21 (Android 5.0)
- Target SDK: API 33+ (recommended)
- Gradle: 7.0+ (auto-configured by Flutter)

**iOS** (⚠️ EXPERIMENTAL/ALPHA):
- Minimum iOS: 14.0
- Xcode: 13.0+
- CocoaPods: Latest version
- Note: iOS support is currently experimental

### Install Claude Code

If you haven't installed Claude Code yet:

```bash
# Visit https://claude.ai/code for installation instructions
```

---

## What You'll Need

### CloudX Credentials

Before starting, have these ready (or use TODO placeholders):

1. **CloudX App Key**
   - Get from: https://app.cloudx.io
   - Example: `8pRtAn-tx7hRen8DmolSf`

2. **Placement Names** (one per ad format)
   - Banner: e.g., `banner_home`, `banner_level_end`
   - Interstitial: e.g., `interstitial_main`, `interstitial_game_over`
   - MREC: e.g., `mrec_main` (if using Medium Rectangle ads)

**Don't have credentials yet?** No problem! The agents will use clear TODO placeholders that you can replace later.

### Your Flutter Project

- Existing Flutter app (any size/complexity)
- Can be:
  - **Greenfield**: No existing ad SDK (CloudX-only integration)
  - **Migration**: Has AdMob or AppLovin (CloudX-first with fallback)

---

## Installation

### Option 1: One-Line Install (Recommended)

Install **all agents** (Android + Flutter):
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/cloudx-io/cloudx-sdk-agents/main/scripts/install.sh)
```

Install **Flutter agents only**:
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/cloudx-io/cloudx-sdk-agents/main/scripts/install.sh) --platform=flutter
```

### Option 2: Manual Install

```bash
# Clone the repository
git clone https://github.com/cloudx-io/cloudx-sdk-agents.git
cd cloudx-sdk-agents

# Install globally (available in all projects)
bash scripts/install.sh --global --platform=flutter

# OR install locally (only in this project)
cd /path/to/your/flutter/project
bash /path/to/cloudx-sdk-agents/scripts/install.sh --local --platform=flutter
```

### Verify Installation

```bash
# Navigate to your Flutter project
cd /path/to/your/flutter/project

# Launch Claude Code
claude

# List available agents
# You should see:
# - cloudx-flutter-integrator
# - cloudx-flutter-auditor
# - cloudx-flutter-build-verifier
# - cloudx-flutter-privacy-checker
```

---

## Quick Start (5 Minutes)

### Step 1: Navigate to Your Flutter Project

```bash
cd /path/to/your/flutter/project
```

### Step 2: Launch Claude Code

```bash
claude
```

### Step 3: Invoke the Integrator Agent

**If you have CloudX credentials**:
```
Use cloudx-flutter-integrator to integrate CloudX SDK with app key: YOUR_APP_KEY
```

**If you don't have credentials yet** (agents will use TODO placeholders):
```
Use cloudx-flutter-integrator to integrate CloudX SDK
```

### Step 4: Wait for Integration (~2-5 minutes)

The agent will:
1. ✅ Detect existing ad SDKs (AdMob/AppLovin) or go standalone
2. ✅ Add CloudX dependency to pubspec.yaml
3. ✅ Initialize SDK in main.dart
4. ✅ Implement ad managers with fallback logic (if applicable)
5. ✅ Update existing ad code (if migrating)
6. ✅ Set up proper lifecycle management

### Step 5: Add Your CloudX Credentials

The agent will show you exactly where to add your credentials:

```
🔑 ACTION REQUIRED: Add Your CloudX Credentials

WHERE TO UPDATE:
1. lib/main.dart:LINE - Replace 'TODO_REPLACE_WITH_YOUR_APP_KEY_FROM_DASHBOARD'
2. lib/screens/home.dart:LINE - Replace 'TODO_CLOUDX_BANNER_PLACEMENT'
3. lib/screens/game.dart:LINE - Replace 'TODO_CLOUDX_INTERSTITIAL_PLACEMENT'
```

### Step 6: Test Your Integration

```bash
# Fetch dependencies
flutter pub get

# Run on device
flutter run

# Check logs for "CloudX SDK initialized successfully"
```

**That's it!** CloudX is integrated in ~5 minutes. 🎉

---

## Integration Modes

The integrator agent automatically detects your project setup and chooses the best approach:

### Mode 1: CloudX-Only (Greenfield)

**When**: No existing ad SDK detected in pubspec.yaml

**What happens**:
- Clean CloudX-only integration
- No fallback logic (simpler code)
- Widget-based or programmatic approach
- Best for new projects

**Example**:
```dart
// Simple banner widget
CloudXBannerView(
  placementName: 'banner_home',
  listener: CloudXAdViewListener(
    onAdLoaded: (ad) => print('Loaded'),
    onAdLoadFailed: (error) => print('Failed: $error'),
  ),
)
```

### Mode 2: CloudX-First with Fallback (Migration)

**When**: `google_mobile_ads` or `applovin_max` detected in pubspec.yaml

**What happens**:
- CloudX tries first
- Falls back to AdMob/AppLovin on error
- Existing ad SDK code preserved
- Best for migrating from existing SDK

**Example**:
```dart
// CloudX first, AdMob fallback
CloudXBannerView(
  placementName: 'banner_home',
  listener: CloudXAdViewListener(
    onAdLoadFailed: (error) {
      // Fallback to AdMob
      _loadAdMobBanner();
    },
  ),
)
```

**The agent decides for you** - no configuration needed!

---

## Agent Overview

### 1. cloudx-flutter-integrator

**Purpose**: Implements CloudX SDK integration

**Capabilities**:
- Auto-detects integration mode (CloudX-only vs. first-look with fallback)
- Adds dependencies
- Initializes SDK
- Creates ad managers
- Updates existing code
- Handles credentials (or uses TODO placeholders)

**When to use**:
- Initial CloudX integration
- Migrating from AdMob/AppLovin
- Adding CloudX to greenfield projects

**Example**:
```
Use cloudx-flutter-integrator to integrate CloudX SDK with app key: MY_KEY
```

### 2. cloudx-flutter-auditor

**Purpose**: Validates integration correctness

**Capabilities**:
- Verifies CloudX initialization
- Checks fallback paths (if applicable)
- Validates lifecycle management
- Checks dispose() methods
- Validates state management
- Checks iOS experimental flag

**When to use**:
- After integration to verify correctness
- Before deploying to production
- When debugging fallback logic
- After making manual changes

**Example**:
```
Use cloudx-flutter-auditor to verify my CloudX integration
```

### 3. cloudx-flutter-build-verifier

**Purpose**: Runs builds and catches errors

**Capabilities**:
- Runs `flutter pub get`
- Runs `flutter analyze`
- Builds Android APK
- Builds iOS (optional, experimental)
- Parses errors with file:line references
- Suggests fixes for common issues

**When to use**:
- After integration before testing
- Before committing code
- To catch compilation errors early
- After making code changes

**Example**:
```
Use cloudx-flutter-build-verifier to build my project
```

### 4. cloudx-flutter-privacy-checker

**Purpose**: Validates privacy compliance

**Capabilities**:
- Checks CCPA compliance
- Checks GPP compliance
- Checks COPPA compliance
- Validates iOS Info.plist
- Validates Android permissions
- Checks privacy API timing

**When to use**:
- Before production deployment
- For compliance audits
- When targeting California/EU users
- For child-directed apps

**Example**:
```
Use cloudx-flutter-privacy-checker to validate privacy compliance
```

---

## Usage Examples

### Example 1: First-Time Integration (Greenfield)

```bash
cd my-new-flutter-app
claude
```

```
Use cloudx-flutter-integrator to integrate CloudX SDK with app key: 8pRtAn-tx7hRen8DmolSf
```

**Result**:
- ✅ CloudX-only integration (no fallback)
- ✅ Banner widgets ready to use
- ✅ Interstitial ads implemented
- ✅ Lifecycle management in place

### Example 2: Migration from AdMob

```bash
cd my-existing-app-with-admob
claude
```

```
Use cloudx-flutter-integrator to integrate CloudX SDK
```

**Result**:
- ✅ CloudX-first with AdMob fallback
- ✅ Existing AdMob code preserved
- ✅ Fallback triggers in onAdLoadFailed
- ✅ State flags track which SDK loaded

### Example 3: Full Integration + Validation Workflow

```bash
cd my-flutter-app
claude
```

```
1. Use cloudx-flutter-integrator to integrate CloudX SDK with app key: MY_KEY
2. Use cloudx-flutter-auditor to verify the integration
3. Use cloudx-flutter-build-verifier to build the project
4. Use cloudx-flutter-privacy-checker to validate privacy compliance
```

**Result**:
- ✅ Complete integration
- ✅ Validation passed
- ✅ Builds successful
- ✅ Privacy compliant
- ✅ Ready for production

### Example 4: Integration Without Credentials (TODO Placeholders)

```bash
cd my-flutter-app
claude
```

```
Use cloudx-flutter-integrator to integrate CloudX SDK
```

**Result**:
- ✅ Integration structure complete
- ⚠️ TODO placeholders for app key and placement names
- ✅ Agent provides detailed list of where to add credentials
- ✅ Ready to add real credentials when available

---

## Testing Your Integration

### Test on Android

```bash
# Run on connected device/emulator
flutter run -d android

# Check logs for initialization
adb logcat | grep "CX:"

# Look for: "CloudX SDK initialized successfully"
```

### Test on iOS (⚠️ Experimental)

```bash
# Install pods first
cd ios && pod install && cd ..

# Run on iOS device/simulator
flutter run -d ios

# Check Xcode console for CloudX logs
```

### Test Fallback Logic (If Applicable)

1. **Enable airplane mode** on your device
2. Launch your app
3. Try to load ads
4. **Verify**:
   - CloudX attempt fails (expected, no network)
   - Fallback SDK attempts (should also fail)
   - No crashes or errors
5. **Disable airplane mode**
6. Try again - ads should load from CloudX

### Test Lifecycle Management

1. Navigate to screen with ads
2. Navigate away (trigger dispose)
3. Come back to screen
4. **Verify**:
   - No memory leaks (check with Flutter DevTools)
   - Ads reload correctly
   - No "setState after dispose" errors

---

## Troubleshooting

### Issue 1: "CloudX SDK initialized successfully" Not Appearing

**Symptoms**: App runs but no CloudX initialization log

**Causes**:
- CloudX.initialize() not called
- App key missing or incorrect
- Initialize called after runApp()

**Fix**:
```bash
claude
```
```
Use cloudx-flutter-auditor to check my CloudX initialization
```

### Issue 2: "allowIosExperimental is required" Error

**Symptoms**: iOS initialization fails

**Cause**: Missing iOS experimental flag

**Fix**:
```dart
// In lib/main.dart
await CloudX.initialize(
  appKey: 'YOUR_KEY',
  allowIosExperimental: true,  // Add this!
);
```

### Issue 3: Ads Not Loading

**Symptoms**: onAdLoadFailed callback fires

**Possible causes**:
- No internet connection
- Invalid placement names
- App key incorrect
- Ad inventory issues

**Debug steps**:
```dart
CloudXAdViewListener(
  onAdLoadFailed: (error) {
    print('Ad load failed: $error');  // Check exact error
  },
)
```

**Common errors**:
- `"Placement not found"` → Check placement name spelling
- `"App key invalid"` → Verify app key in dashboard
- `"Network error"` → Check internet connection

### Issue 4: "setState() called after dispose()" Error

**Symptoms**: Error when navigating away from ad screen

**Cause**: Missing destroyAd() in dispose or missing mounted check

**Fix**:
```dart
@override
void dispose() {
  if (_adId != null) {
    CloudX.destroyAd(adId: _adId!);  // Always destroy!
  }
  super.dispose();
}

// And check mounted before setState
if (mounted) {
  setState(() { ... });
}
```

### Issue 5: Build Failures After Integration

**Symptoms**: `flutter build apk` fails

**Fix**:
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build apk

# If still failing, run build verifier
claude
```
```
Use cloudx-flutter-build-verifier to diagnose build issues
```

### Issue 6: Fallback Not Triggering

**Symptoms**: CloudX fails but AdMob doesn't load

**Causes**:
- Fallback code missing in onAdLoadFailed
- State flags incorrect
- Fallback SDK not initialized

**Fix**:
```bash
claude
```
```
Use cloudx-flutter-auditor to check my fallback logic
```

### Issue 7: iOS Build Fails (CocoaPods)

**Symptoms**: `pod install` fails or build errors

**Fix**:
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter build ios --no-codesign
```

**Check Podfile**:
```ruby
# Must have iOS 14.0+
platform :ios, '14.0'
```

---

## Next Steps

### After Successful Integration

1. **Add Real Credentials** (if using TODO placeholders)
   - Get app key from CloudX dashboard
   - Create placements for each ad format
   - Replace all TODO values in code

2. **Test Thoroughly**
   - Test on multiple devices (Android/iOS)
   - Test fallback logic (airplane mode)
   - Test lifecycle (navigate away and back)
   - Test different ad formats

3. **Privacy Compliance**
   ```
   Use cloudx-flutter-privacy-checker to validate privacy compliance
   ```

4. **Production Preparation**
   - Disable logging: Remove `CloudX.setLoggingEnabled(true)`
   - Set production environment: `CloudX.setEnvironment('production')`
   - Build release APK: `flutter build apk --release`
   - Build release AAB: `flutter build appbundle --release`

5. **Documentation**
   - Read [Integration Guide](./INTEGRATION_GUIDE.md) for advanced patterns
   - Read [Orchestration Guide](./ORCHESTRATION.md) for multi-agent workflows

### Resources

- **CloudX Flutter SDK**: https://github.com/cloudx-io/cloudx-flutter
- **CloudX Dashboard**: https://app.cloudx.io
- **Agent Issues**: https://github.com/cloudx-io/cloudx-sdk-agents/issues
- **Flutter SDK Docs**: https://pub.dev/packages/cloudx_flutter

### Get Help

**Issue with agents?**
- Open issue: https://github.com/cloudx-io/cloudx-sdk-agents/issues
- Include: Agent name, error message, Flutter version

**Issue with CloudX SDK?**
- Open issue: https://github.com/cloudx-io/cloudx-flutter/issues
- Include: SDK version, error message, minimal reproduction

**General questions?**
- Email: mobile@cloudx.io

---

## Platform-Specific Notes

### iOS (⚠️ EXPERIMENTAL/ALPHA)

**Current Status**: iOS support is in alpha and experimental

**Known Limitations**:
- May have stability issues
- Not all features fully tested on iOS
- Not recommended for production iOS apps yet

**Requirements**:
- Must set `allowIosExperimental: true` during initialization
- Minimum iOS 14.0
- CocoaPods installed

**When iOS Support is Stable**:
- We'll remove the experimental flag requirement
- Update these docs
- Announce on GitHub releases

### Android

**Status**: ✅ Production-ready

**Requirements**:
- Minimum API 21 (Android 5.0)
- Auto-configured by CloudX SDK

---

## What's Next?

You've successfully set up CloudX agents! Here's what to explore:

1. **[Integration Guide](./INTEGRATION_GUIDE.md)** - Deep dive into integration patterns
2. **[Orchestration Guide](./ORCHESTRATION.md)** - Multi-agent workflows and advanced patterns
3. **CloudX Dashboard** - Create placements, view analytics, manage settings

**Happy monetizing!** 🚀
