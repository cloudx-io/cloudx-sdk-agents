# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This repository contains specialized Claude Code agents for automating CloudX SDK integration across multiple platforms (Android, Flutter, and future iOS). The agents help app publishers integrate CloudX SDK as a primary ad mediation layer with proper fallback to AdMob/AppLovin, reducing integration time from 4-6 hours to ~20 minutes.

**Supported Platforms:**
- **Android** (v0.8.0) - 4 agents - Production ready
- **Flutter** (v0.1.2) - 4 agents - Production ready
- **iOS** - Coming soon

## Architecture Overview

### Multi-Agent System (Per Platform)
The repository implements a specialized multi-agent architecture where each agent handles a specific aspect of SDK integration. Each platform has its own set of 4 specialized agents:

```
User/Main Agent (Coordinator)
    │
    ├──► Android Agents
    │    ├── @agent-cloudx-android-integrator     (Implementation)
    │    ├── @agent-cloudx-android-auditor        (Validation)
    │    ├── @agent-cloudx-android-build-verifier (Testing)
    │    └── @agent-cloudx-android-privacy-checker (Compliance)
    │
    └──► Flutter Agents
         ├── @agent-cloudx-flutter-integrator     (Implementation)
         ├── @agent-cloudx-flutter-auditor        (Validation)
         ├── @agent-cloudx-flutter-build-verifier (Testing)
         └── @agent-cloudx-flutter-privacy-checker (Compliance)
```

**Agent Definitions**: All agents are defined as markdown files in `.claude/agents/<platform>/` with frontmatter specifying:
- `name`: Agent identifier (e.g., `cloudx-flutter-integrator`) that maps to Claude invocation `@agent-cloudx-flutter-integrator`
- `description`: When to invoke the agent (critical for auto-routing)
- `tools`: Available tools (Read, Write, Edit, Grep, Glob, Bash)
- `model`: Preferred model (sonnet, haiku, opus)

### Key Components

1. **Agent Files** (`.claude/agents/<platform>/`)
   - **Android** (`.claude/agents/android/`)
     - `cloudx-android-integrator.md` → `@agent-cloudx-android-integrator` (implements SDK integration with fallback logic)
     - `cloudx-android-auditor.md` → `@agent-cloudx-android-auditor` (validates that existing fallback paths remain intact)
     - `cloudx-android-build-verifier.md` → `@agent-cloudx-android-build-verifier` (runs Gradle builds and reports errors)
     - `cloudx-android-privacy-checker.md` → `@agent-cloudx-android-privacy-checker` (validates GDPR/CCPA/COPPA compliance)

   - **Flutter** (`.claude/agents/flutter/`)
     - `cloudx-flutter-integrator.md` → `@agent-cloudx-flutter-integrator` (implements SDK integration with fallback logic)
     - `cloudx-flutter-auditor.md` → `@agent-cloudx-flutter-auditor` (validates that existing fallback paths remain intact)
     - `cloudx-flutter-build-verifier.md` → `@agent-cloudx-flutter-build-verifier` (runs Flutter builds and reports errors)
     - `cloudx-flutter-privacy-checker.md` → `@agent-cloudx-flutter-privacy-checker` (validates GDPR/CCPA/COPPA compliance)

2. **Documentation** (`docs/<platform>/`)
   - **Android** (`docs/android/`)
     - `SETUP.md` - Installation and setup instructions
     - `INTEGRATION_GUIDE.md` - Complete integration guide with examples
     - `ORCHESTRATION.md` - Agent coordination and workflow patterns

   - **Flutter** (`docs/flutter/`)
     - `SETUP.md` - Installation and setup instructions
     - `INTEGRATION_GUIDE.md` - Complete integration guide with examples
     - `ORCHESTRATION.md` - Agent coordination and workflow patterns

3. **Scripts** (`scripts/`)
   - `install.sh` - Installs agents globally or locally (supports --platform flag)
   - **Android** (`scripts/android/`)
     - `validate_agent_apis.sh` - Validates agent documentation matches SDK version
     - `check_api_coverage.sh` - Checks API documentation coverage
   - **Flutter** (`scripts/flutter/`)
     - `validate_agent_apis.sh` - Validates agent documentation matches SDK version

4. **SDK Version Tracking** (`SDK_VERSION.yaml`)
   - Tracks which CloudX SDK version the agents are synchronized with (per platform)
   - Documents critical API signatures that agents depend on (per platform)
   - Lists files that contain API references requiring updates (per platform)
   - Provides update checklist for SDK version changes (per platform)

## CloudX SDK Integration Pattern (All Platforms)

The agents implement a "first look" pattern where CloudX SDK is tried first, with fallback to existing ad SDKs:

```
CloudX SDK (Primary - First Look)
    │
    │ onAdLoadFailed (Android/Flutter)
    ▼
Secondary Mediation (Fallback)
    ├── Google AdMob
    └── AppLovin MAX
```

**Important**: If no existing ad SDK is detected, the integrator will implement **standalone CloudX integration** (no fallback).

## Platform-Specific Integration Details

### Android CloudX SDK API Reference (v0.8.0)

**Critical Implementation Details**:
- CloudX SDK **must** be initialized before attempting ad loads
- All CloudX ad types require **explicit `.load()` calls** (no auto-loading)
- Fallback logic triggers in `onAdLoadFailed` callbacks
- AdMob ads are **single-use** (must reload after dismiss)
- AppLovin ads are **reusable** (can call loadAd() on same instance)

**Initialization**:
```kotlin
CloudX.initialize(
    initParams = CloudXInitializationParams(appKey = "YOUR_KEY"),
    listener = object : CloudXInitializationListener {
        override fun onInitialized() {}
        override fun onInitializationFailed(cloudXError: CloudXError) {}
    }
)
```

**Banner Ads**:
```kotlin
val banner = CloudX.createBanner(placementName = "banner_home")
banner.listener = object : CloudXAdViewListener {
    override fun onAdLoaded(cloudXAd: CloudXAd) {}
    override fun onAdLoadFailed(cloudXError: CloudXError) { /* fallback */ }
}
banner.load() // MUST call explicitly
```

**Interstitial Ads**:
```kotlin
val interstitial = CloudX.createInterstitial(placementName = "interstitial_main")
interstitial.listener = object : CloudXInterstitialListener {
    override fun onAdLoaded(cloudXAd: CloudXAd) {}
    override fun onAdLoadFailed(cloudXError: CloudXError) { /* fallback */ }
}
interstitial.load() // MUST call explicitly
// Show when ready: if (interstitial.isAdReady) interstitial.show()
```

**Rewarded Ads**:
```kotlin
val rewarded = CloudX.createRewardedInterstitial(placementName = "rewarded_main")
rewarded.listener = object : CloudXRewardedInterstitialListener {
    override fun onAdLoaded(cloudXAd: CloudXAd) {}
    override fun onAdLoadFailed(cloudXError: CloudXError) { /* fallback */ }
    override fun onUserRewarded(cloudXAd: CloudXAd) { /* grant reward */ }
}
rewarded.load() // MUST call explicitly
```

**Privacy Configuration**:
```kotlin
CloudX.setPrivacy(
    CloudXPrivacy(
        isUserConsent = true,        // GDPR consent (nullable)
        isAgeRestrictedUser = false  // COPPA flag (nullable)
    )
)
```

**Key API Notes**:
- `isAdReady` is a **property**, not a method (use `if (ad.isAdReady)`)
- `show()` method takes **no parameters**
- Listener callbacks use `CloudXAd` parameter (not just `CloudXError`)
- Privacy API fields are nullable (null = not set)

## Development Commands

### Installation
```bash
# Install agents locally to current project (default)
bash scripts/install.sh

# Install agents locally (explicit)
bash scripts/install.sh --local

# Install agents globally (available across all projects)
bash scripts/install.sh --global

# Install from specific branch
bash scripts/install.sh --branch=develop
```

### Validation
```bash
# Validate agent API references against SDK
bash scripts/validate_agent_apis.sh

# Check API documentation coverage
bash scripts/check_api_coverage.sh
```

### Testing Agents
```bash
# Navigate to a test Android project
cd /path/to/android/project

# Launch Claude Code
claude

# Test integration agent
"Use @agent-cloudx-android-integrator to integrate CloudX SDK with app key: test-key"

# Test auditor
"Use @agent-cloudx-android-auditor to verify fallback paths"

# Test build verifier
"Use @agent-cloudx-android-build-verifier to run ./gradlew build"

# Test privacy checker
"Use @agent-cloudx-android-privacy-checker to validate GDPR compliance"
```

## Agent Development Guidelines

### When Modifying Agents

1. **Maintain API Accuracy**: All code examples must match SDK version in `SDK_VERSION.yaml`
2. **Test Against Real Projects**: Validate changes with actual Android apps
3. **Update Documentation**: Keep `docs/` in sync with agent capabilities
4. **Run Validation**: Execute `validate_agent_apis.sh` before committing
5. **Version Tracking**: Update `SDK_VERSION.yaml` when SDK version changes

### Agent Invocation Patterns

**Explicit (Recommended)**:
```
Use @agent-cloudx-android-integrator to integrate CloudX SDK
```

**Implicit (Auto-routing)**:
```
Integrate CloudX SDK into my app
→ Claude Code routes to @agent-cloudx-android-integrator based on description
```

### Agent Coordination

**Sequential (Common)**:
```
Integrator → Auditor → Build Verifier → Privacy Checker
```

**Iterative (Debugging)**:
```
1. Integrator makes changes
2. Build Verifier tests → FAIL
3. Integrator fixes errors
4. Build Verifier tests → PASS
5. Auditor validates → PASS
```

**Parallel (Advanced)**:
```
Auditor + Privacy Checker (both read-only, no conflicts)
```

## Critical API Validation

### SDK Version Synchronization

The agents must stay synchronized with CloudX SDK public APIs. When SDK version changes:

1. Update `sdk_version` in `SDK_VERSION.yaml`
2. Run `scripts/validate_agent_apis.sh` to check for breaking changes
3. Update agent files with new API names/signatures
4. Update code examples in `docs/INTEGRATION_GUIDE.md`
5. Test agents against real Android projects
6. Update `agents_last_updated` date

### Validation Coverage

**Currently Validated** (smoke_test level):
- Class and interface names exist in SDK
- Factory method names (createBanner, createInterstitial, etc.)
- Privacy API class and field names
- Deprecated API patterns not in agent docs
- Basic callback signature patterns

**Not Currently Validated**:
- Method signatures (parameter count, types, order)
- Return types of methods
- All callback signatures (only checks subset)
- Code examples compile against SDK
- New SDK features documented
- Property vs method distinctions
- Complete API coverage (~20% currently checked)

**Known Risks**:
- SDK could add new ad formats (native, MREC) without agents knowing
- Method parameters could change without validation catching it
- Breaking changes in minor versions might not be caught

## Common Pitfalls

### CloudX SDK Integration
1. **Forgetting explicit `.load()` calls** - CloudX ads don't auto-load
2. **Wrong `isAdReady` usage** - It's a property, not a method
3. **Missing initialization check** - Must initialize before loading ads
4. **Incorrect callback parameter types** - Use `CloudXAd`, not just error

### AdMob Integration
1. **Missing FullScreenContentCallback** - Must set before calling `show()`
2. **Reusing single-use ads** - Must reload after dismiss
3. **Blocking main thread** - Initialize on background thread
4. **Missing completion callback** - Wait for initialization before loading ads

### AppLovin Integration
1. **Wrong mediation provider** - Must set to `AppLovinMediationProvider.MAX`
2. **No retry logic** - Implement exponential backoff for load failures
3. **Missing isReady check** - Verify before calling `showAd()`

### Fallback Logic
1. **Missing state flags** - Track which SDK successfully loaded
2. **Simultaneous ad attempts** - Only load from one source at a time
3. **Not clearing fallback** - Clear when CloudX succeeds
4. **Wrong lifecycle handling** - Respect ad lifecycle callbacks

## File Structure Reference

```
cloudx-sdk-agents/
├── .claude/
│   └── agents/                    # Agent definitions (markdown files)
├── .github/
│   └── workflows/                 # CI/CD workflows
├── docs/
│   ├── SETUP.md                   # Installation guide
│   ├── INTEGRATION_GUIDE.md       # Complete integration guide
│   └── ORCHESTRATION.md           # Agent coordination guide
├── scripts/
│   ├── install.sh                 # Agent installer
│   ├── validate_agent_apis.sh     # API validation script
│   └── check_api_coverage.sh      # Coverage checker
├── SDK_VERSION.yaml               # SDK version tracking
└── README.md                      # Quick start guide
```

## Additional Resources

- **CloudX SDK Repository**: https://github.com/cloudx-io/cloudexchange.android.sdk
- **Issues**: https://github.com/cloudx-io/cloudx-sdk-agents/issues
- **Claude Code Documentation**: https://claude.ai/code
