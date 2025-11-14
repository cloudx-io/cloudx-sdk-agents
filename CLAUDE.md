# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repository contains **AI agents for automating CloudX SDK integration** across Android and Flutter platforms. Each platform has 4 specialized agents that reduce SDK integration time from 4-6 hours to ~20 minutes by automating dependency management, initialization, fallback logic, build verification, and privacy compliance.

**Platforms:**
- Android (SDK v0.6.1) - Production ready
- Flutter (SDK v0.1.2) - Production ready

## Key Architecture Patterns

### Multi-Platform Agent System
```
.claude/agents/
├── android/           # 4 Android-specific agents
│   ├── cloudx-android-integrator.md        (@agent-cloudx-android-integrator)
│   ├── cloudx-android-auditor.md           (@agent-cloudx-android-auditor)
│   ├── cloudx-android-build-verifier.md    (@agent-cloudx-android-build-verifier)
│   └── cloudx-android-privacy-checker.md   (@agent-cloudx-android-privacy-checker)
└── flutter/           # 4 Flutter-specific agents
    ├── cloudx-flutter-integrator.md        (@agent-cloudx-flutter-integrator)
    ├── cloudx-flutter-auditor.md           (@agent-cloudx-flutter-auditor)
    ├── cloudx-flutter-build-verifier.md    (@agent-cloudx-flutter-build-verifier)
    └── cloudx-flutter-privacy-checker.md   (@agent-cloudx-flutter-privacy-checker)
```

### Integration Pattern: "First Look with Fallback"
Agents implement CloudX as primary with automatic fallback to existing ad SDKs:
```
CloudX SDK (Primary - First Look)
    │
    │ onAdLoadFailed callback
    ▼
Secondary Mediation (Fallback)
    ├── Google AdMob
    └── AppLovin MAX
```

If no existing ad SDK detected → standalone CloudX integration (no fallback)

## Development Commands

### Installation and Testing
```bash
# Install agents locally (current project)
bash scripts/install.sh

# Install globally (available across all projects)
bash scripts/install.sh --global

# Install platform-specific agents
bash scripts/install.sh --platform=android
bash scripts/install.sh --platform=flutter

# Install from specific branch
bash scripts/install.sh --branch=develop
```

### Validation
```bash
# Validate Android agent API references
bash scripts/android/validate_agent_apis.sh

# Check Android API coverage
bash scripts/android/check_api_coverage.sh

# Validate Flutter agent API references
bash scripts/flutter/validate_agent_apis.sh
```

### Testing Agents Locally
```bash
# Navigate to test project
cd /path/to/test/android-or-flutter-project

# Launch Claude Code
claude

# Test specific agent
"Use @agent-cloudx-android-integrator to integrate CloudX SDK"
```

## Critical SDK API References

### Android CloudX SDK (v0.6.1)

**Key Implementation Rules**:
- Must initialize CloudX before loading ads
- All ad types require **explicit `.load()` calls** (NO auto-loading)
- Fallback triggers in `onAdLoadFailed` callbacks
- `isAdReady` is a **property** (not method): `if (ad.isAdReady)`
- `show()` takes **no parameters**
- AdMob ads are single-use; AppLovin ads are reusable

**Factory Methods**:
```kotlin
CloudX.initialize(CloudXInitializationParams(appKey = "KEY"), listener)
CloudX.createBanner(placementName = "banner_home")
CloudX.createInterstitial(placementName = "interstitial_main")
CloudX.createRewardedInterstitial(placementName = "rewarded_main")
CloudX.setPrivacy(CloudXPrivacy(isUserConsent, isAgeRestrictedUser))
```

### Flutter CloudX SDK (v0.1.2)

**Key Differences from Android**:
- All methods return `Future<T>` (async)
- Widget-based banners: `CloudXBannerView`, `CloudXMRECView`
- Separate create/load/show/destroy lifecycle
- Privacy: `setCCPAPrivacyString`, `setGPPString`, `setIsAgeRestrictedUser`

**Factory Methods**:
```dart
await CloudX.initialize(appKey: "KEY")
await CloudX.createBanner(placementName: "banner", adId: "id")
await CloudX.loadBanner(adId: "id")
await CloudX.showBanner(adId: "id")
await CloudX.destroyAd(adId: "id")
```

## Repository Structure

```
cloudx-sdk-agents/
├── .claude/agents/
│   ├── android/                   # Android agent definitions
│   │   ├── cloudx-android-integrator.md
│   │   ├── cloudx-android-auditor.md
│   │   ├── cloudx-android-build-verifier.md
│   │   └── cloudx-android-privacy-checker.md
│   └── flutter/                   # Flutter agent definitions
│       ├── cloudx-flutter-integrator.md
│       ├── cloudx-flutter-auditor.md
│       ├── cloudx-flutter-build-verifier.md
│       └── cloudx-flutter-privacy-checker.md
├── docs/
│   ├── android/                   # Android documentation
│   │   ├── SETUP.md
│   │   ├── INTEGRATION_GUIDE.md
│   │   └── ORCHESTRATION.md
│   └── flutter/                   # Flutter documentation
│       ├── SETUP.md
│       ├── INTEGRATION_GUIDE.md
│       └── ORCHESTRATION.md
├── scripts/
│   ├── install.sh                 # Agent installer (supports --platform)
│   ├── android/
│   │   ├── validate_agent_apis.sh
│   │   └── check_api_coverage.sh
│   └── flutter/
│       └── validate_agent_apis.sh
├── SDK_VERSION.yaml               # SDK version tracking per platform
├── AGENTS.md                      # Contributor guidelines
├── GUIDE_FOR_OTHER_SDKS.md        # Blueprint for iOS/Unity/RN agents
└── README.md                      # Quick start guide
```

## Agent Modification Guidelines

### Before Making Changes
1. Check `SDK_VERSION.yaml` for current SDK versions
2. Read `AGENTS.md` for contributor guidelines
3. Review relevant platform docs in `docs/<platform>/`

### After Making Changes
1. Run validation: `bash scripts/<platform>/validate_agent_apis.sh`
2. Test agent with real project (Android or Flutter app)
3. Update `SDK_VERSION.yaml` if API signatures changed
4. Update `docs/<platform>/` if agent capabilities changed
5. Commit with clear message: `"Update [platform] [agent-name]: [description]"`

### Validation Coverage (Important Limitations)
**What validation checks:**
- Class/interface names exist
- Factory method names correct
- No deprecated API patterns

**What validation DOES NOT check:**
- Method signatures (param types/order)
- Return types
- Property vs method distinction
- New SDK features added
- Compile correctness of code examples

**Implication**: Always test agents manually against real projects after making changes.

## Common Integration Pitfalls

### Android-Specific
- Forgetting explicit `.load()` calls (CloudX doesn't auto-load)
- Using `isAdReady()` instead of `isAdReady` (property, not method)
- AdMob ads are single-use (reload after dismiss)
- AppLovin requires `AppLovinMediationProvider.MAX`

### Flutter-Specific
- Forgetting `await` on async calls
- Not calling `destroyAd()` in dispose
- Missing platform-specific permissions (iOS/Android)

### Cross-Platform
- Initializing SDK before loading ads
- Implementing fallback in `onAdLoadFailed` callbacks
- Privacy API calls before ad initialization

## Resources

- Android SDK: https://github.com/cloudx-io/cloudexchange.android.sdk
- Flutter SDK: https://github.com/cloudx-io/cloudx-flutter
- Issues: https://github.com/cloudx-io/cloudx-sdk-agents/issues
- Claude Code docs: https://claude.ai/code
