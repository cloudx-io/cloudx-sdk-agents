# CloudX SDK - Claude Code Agents (Multi-Platform)

Automated CloudX SDK integration in ~20 minutes with AI-powered agents.

Reduce integration time from 4-6 hours to 20 minutes with specialized AI agents that handle boilerplate code, implement fallback logic, and validate compliance.

## Supported Platforms

| Platform | Status | SDK Version | Agents |
|----------|--------|-------------|--------|
| **Android** | ✅ Production | v0.11.0 | 4 agents |
| **Flutter** | ✅ Production | v0.1.2 | 4 agents |
| **iOS** | 🚧 Coming Soon | TBD | TBD |

## Quick Start

### Install All Agents
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/cloudx-io/cloudx-sdk-agents/main/scripts/install.sh)
```

### Install Platform-Specific Agents
```bash
# Android only
bash scripts/install.sh --platform=android

# Flutter only
bash scripts/install.sh --platform=flutter
```

### Use Agents

**Android:**
```bash
cd your-android-project
claude
"Use @agent-cloudx-android-integrator to integrate CloudX SDK with app key: YOUR_KEY"
```

**Flutter:**
```bash
cd your-flutter-project
claude
"Use @agent-cloudx-flutter-integrator to integrate CloudX SDK with app key: YOUR_KEY"
```

## Agents by Platform

### Android Agents
- **@agent-cloudx-android-integrator** - Implements CloudX with AdMob/AppLovin fallback
- **@agent-cloudx-android-auditor** - Validates fallback paths remain intact
- **@agent-cloudx-android-build-verifier** - Runs Gradle builds and catches errors
- **@agent-cloudx-android-privacy-checker** - Validates GDPR/CCPA/COPPA compliance

[📖 Android Documentation](./docs/android/)

### Flutter Agents
- **@agent-cloudx-flutter-integrator** - Implements CloudX with AdMob/AppLovin fallback
- **@agent-cloudx-flutter-auditor** - Validates fallback paths remain intact
- **@agent-cloudx-flutter-build-verifier** - Runs Flutter builds and catches errors
- **@agent-cloudx-flutter-privacy-checker** - Validates GDPR/CCPA/COPPA compliance

[📖 Flutter Documentation](./docs/flutter/)

## Documentation

### Android
- [Setup Guide](./docs/android/SETUP.md)
- [Integration Guide](./docs/android/INTEGRATION_GUIDE.md)
- [Orchestration](./docs/android/ORCHESTRATION.md)

### Flutter
- [Setup Guide](./docs/flutter/SETUP.md)
- [Integration Guide](./docs/flutter/INTEGRATION_GUIDE.md)
- [Orchestration](./docs/flutter/ORCHESTRATION.md)

### General
- [Guide for Implementing Agents for Other SDKs](./GUIDE_FOR_OTHER_SDKS.md)

## Resources

- **Android SDK:** https://github.com/cloudx-io/cloudx-android
- **Flutter SDK:** https://github.com/cloudx-io/cloudx-flutter
- **Issues:** https://github.com/cloudx-io/cloudx-sdk-agents/issues

## Key Features

- ✅ **Fast Integration** - 20 minutes vs. 4-6 hours manual
- ✅ **Fallback Logic** - Automatic fallback to AdMob/AppLovin
- ✅ **Privacy Compliance** - GDPR, CCPA, COPPA validation
- ✅ **Build Verification** - Catches errors before runtime
- ✅ **Best Practices** - Implements recommended patterns automatically

## How It Works

1. **Install agents** - One-line installer for your platform
2. **Invoke integrator** - AI agent implements SDK with fallback
3. **Validate** - Auditor checks fallback paths are intact
4. **Build** - Build verifier catches compilation errors
5. **Check privacy** - Privacy checker validates compliance
6. **Ship** - Production-ready integration in ~20 minutes

## Contributing

See [GUIDE_FOR_OTHER_SDKS.md](./GUIDE_FOR_OTHER_SDKS.md) for implementing agents for iOS, Unity, React Native, or other platforms.
