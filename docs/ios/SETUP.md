# CloudX SDK Integration with Claude Code Agents - iOS

Automate your CloudX iOS SDK integration using AI-powered Claude Code agents. This guide will help you set up and use CloudX's specialized integration agents to integrate the SDK in minutes instead of hours.

## What Are Claude Code Agents?

Claude Code agents are specialized AI assistants that automate complex integration tasks. CloudX provides 4 specialized agents for iOS that:

- **@agent-cloudx-ios-integrator**: Implements CloudX SDK first look with fallback to AdMob/AppLovin
- **@agent-cloudx-ios-auditor**: Validates that existing ad fallback paths remain intact
- **@agent-cloudx-ios-build-verifier**: Runs Xcode builds and catches compilation errors
- **@agent-cloudx-ios-privacy-checker**: Ensures GDPR, CCPA, COPPA, and ATT compliance

## Benefits

✅ **Fast Integration**: 20 minutes vs 4-6 hours manual work
✅ **Automatic Fallback**: Preserves your existing AdMob/AppLovin setup
✅ **Privacy Compliant**: Validates GDPR/CCPA/ATT handling automatically
✅ **Build Verified**: Catches errors before runtime
✅ **Best Practices**: Implements proper initialization order and delegate patterns
✅ **Both Languages**: Supports Objective-C and Swift projects

---

## Prerequisites

### 1. Install Claude Code

You need Claude Code (Anthropic's AI coding assistant) installed on your machine.

**macOS / Linux (Homebrew):**
```bash
brew install --cask claude-code
```

**macOS / Linux (curl):**
```bash
curl -fsSL https://claude.ai/install.sh | bash
```

For other platforms, visit: [https://claude.ai/code](https://claude.ai/code)

### 2. Verify Installation

```bash
claude --version
```

You should see the Claude Code version number.

---

## Installation

### Install CloudX iOS Agents

**One-line install (recommended):**
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/cloudx-io/cloudx-sdk-agents/main/scripts/install.sh) --platform=ios
```

**Or install all platforms:**
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/cloudx-io/cloudx-sdk-agents/main/scripts/install.sh)
```

**Manual installation:**
```bash
# Clone the repository
git clone https://github.com/cloudx-io/cloudx-sdk-agents.git
cd cloudx-sdk-agents

# Install iOS agents locally
bash scripts/install.sh --platform=ios --local

# Or install globally
bash scripts/install.sh --platform=ios --global
```

### Verify Agent Installation

```bash
# List installed agents
ls ~/.claude/agents/ | grep cloudx-ios

# You should see:
# cloudx-ios-integrator.md
# cloudx-ios-auditor.md
# cloudx-ios-build-verifier.md
# cloudx-ios-privacy-checker.md
```

---

## Quick Start: First Integration

### Step 1: Navigate to Your iOS Project

```bash
cd /path/to/your/ios/project
```

Your project should contain either:
- `YourApp.xcodeproj` (standalone Xcode project)
- `YourApp.xcworkspace` (CocoaPods project)
- `Package.swift` (Swift Package Manager)

### Step 2: Launch Claude Code

```bash
claude
```

Claude Code will open in your terminal with context of your project.

### Step 3: Invoke the Integrator Agent

**Basic integration:**
```
Use @agent-cloudx-ios-integrator to integrate CloudX SDK with app key: YOUR_APP_KEY
```

**With fallback (if you have AdMob):**
```
Use @agent-cloudx-ios-integrator to integrate CloudX SDK with AdMob fallback using app key: YOUR_APP_KEY
```

**With fallback (if you have AppLovin):**
```
Use @agent-cloudx-ios-integrator to integrate CloudX SDK with AppLovin fallback using app key: YOUR_APP_KEY
```

### What the Agent Does

The integrator agent will:

1. ✅ Detect your project type (CocoaPods, SPM, or Xcode)
2. ✅ Detect existing ad SDKs (AdMob, AppLovin)
3. ✅ Add CloudX SDK dependency to Podfile or Package.swift
4. ✅ Add CloudX initialization to AppDelegate
5. ✅ Create ad loading code with proper delegates
6. ✅ Implement fallback logic (if applicable)
7. ✅ Add privacy configuration (CCPA, GDPR, COPPA)
8. ✅ Provide both Objective-C and Swift examples

### Step 4: Install Dependencies

**For CocoaPods:**
```bash
pod install
```

**For SPM:**
Xcode will automatically resolve packages, or run:
```bash
xcodebuild -resolvePackageDependencies
```

### Step 5: Verify Integration

**Run the auditor:**
```
Use @agent-cloudx-ios-auditor to verify my CloudX integration
```

**Run the build verifier:**
```
Use @agent-cloudx-ios-build-verifier to build my project
```

**Check privacy compliance:**
```
Use @agent-cloudx-ios-privacy-checker to validate privacy settings
```

### Step 6: Test in Xcode

1. Open your `.xcworkspace` (CocoaPods) or `.xcodeproj`
2. Build and run (⌘R)
3. Check console for CloudX initialization logs
4. Test ad loading in your app

---

## Integration Modes

### CloudX-Only Mode (Greenfield)

**When:** No existing ad SDKs detected

**What happens:**
- CloudX SDK is added as the sole ad provider
- Simple, direct integration
- No fallback logic needed

**Example usage:**
```
Use @agent-cloudx-ios-integrator to integrate CloudX SDK with app key: YOUR_KEY
```

### First-Look with AdMob Fallback (Migration)

**When:** AdMob SDK detected in project

**What happens:**
- CloudX SDK is tried first (primary)
- AdMob SDK remains as fallback
- Fallback triggers automatically on CloudX failure
- Both SDKs receive privacy signals

**Example usage:**
```
Use @agent-cloudx-ios-integrator to integrate CloudX SDK with AdMob fallback using app key: YOUR_KEY
```

### First-Look with AppLovin Fallback (Migration)

**When:** AppLovin SDK detected in project

**What happens:**
- CloudX SDK is tried first (primary)
- AppLovin SDK remains as fallback
- Fallback triggers automatically on CloudX failure
- Both SDKs receive privacy signals

**Example usage:**
```
Use @agent-cloudx-ios-integrator to integrate CloudX SDK with AppLovin fallback using app key: YOUR_KEY
```

---

## Supported Ad Formats

### Banner Ads
- Standard banner (320x50)
- Auto-loads after creation
- Requires UIViewController

### MREC Ads
- Medium rectangle (300x250)
- Auto-loads after creation
- Requires UIViewController

### Interstitial Ads
- Full-screen ads
- Auto-loads after creation
- Use `showFromViewController:` to display

### Rewarded Ads
- Video ads with rewards
- Auto-loads after creation
- Use `showFromViewController:` to display
- Reward callback: `rewardedUserDidEarnReward:`

### Native Ads
- Custom layout native ads
- Auto-loads after creation
- Requires UIViewController

---

## Language Support

All agents provide examples in **both Objective-C and Swift**.

### Objective-C Projects

Agents will generate:
- `.m` implementation files
- Delegate protocol conformance
- Proper header imports

### Swift Projects

Agents will generate:
- `.swift` files
- Protocol conformance with extensions
- Modern Swift syntax

### Mixed Projects

Agents detect both languages and provide appropriate examples for your codebase.

---

## Privacy & Compliance

### ATT (App Tracking Transparency)

**Required for iOS 14.5+**

The integrator automatically:
- Adds `NSUserTrackingUsageDescription` to Info.plist
- Implements `requestTrackingAuthorization`
- Initializes SDK after ATT response

### CCPA Compliance

```swift
// Automatically added before SDK initialization
CloudXCore.setCCPAPrivacyString("1YNN")
```

### GDPR Compliance

```swift
// Automatically added (future server support)
CloudXCore.setIsUserConsent(true)
```

### COPPA Compliance

```swift
// For child-directed apps
CloudXCore.setIsAgeRestrictedUser(true)
```

Validate with:
```
Use @agent-cloudx-ios-privacy-checker to validate my privacy implementation
```

---

## Troubleshooting

### "Module 'CloudXCore' not found"

**Cause:** Pods not installed or SPM not resolved

**Fix:**
```bash
# CocoaPods
pod install

# SPM (Xcode will auto-resolve, or)
xcodebuild -resolvePackageDependencies
```

### "No such module 'GoogleMobileAds'" (Fallback)

**Cause:** AdMob SDK not properly installed

**Fix:**
```bash
# Ensure AdMob is in Podfile
pod 'Google-Mobile-Ads-SDK'

# Install
pod install
```

### Build Fails After Integration

**Solution:**
```
Use @agent-cloudx-ios-build-verifier to diagnose build errors
```

The build verifier will parse errors and provide specific fixes.

### Ads Not Loading

**Check:**
1. SDK initialization succeeded (check console logs)
2. App key is correct
3. Internet connection available
4. Privacy settings configured
5. ATT permission granted (iOS 14.5+)

**Verify:**
```
Use @agent-cloudx-ios-auditor to check my integration
```

### Privacy/ATT Issues

**Solution:**
```
Use @agent-cloudx-ios-privacy-checker to validate compliance
```

---

## Project Structure

After integration, your project will have:

```
YourApp/
├── Podfile (updated with CloudX SDK)
├── YourApp.xcworkspace
├── YourApp/
│   ├── AppDelegate.swift (or .m) - CloudX initialization added
│   ├── Info.plist - Privacy declarations added
│   └── ViewControllers/
│       └── BannerViewController.swift - CloudX ad implementation
```

---

## Next Steps

### 1. Complete the Integration

Follow the [Integration Guide](./INTEGRATION_GUIDE.md) for detailed examples of:
- All ad formats (banner, interstitial, rewarded, native)
- Both Objective-C and Swift code
- Advanced fallback patterns
- Memory management

### 2. Learn Agent Orchestration

See [Orchestration Guide](./ORCHESTRATION.md) for:
- Multi-agent workflows
- Sequential vs parallel execution
- Debugging patterns

### 3. Test Your Integration

1. Run in Xcode simulator
2. Test on physical device
3. Verify ads load correctly
4. Test fallback behavior (if applicable)
5. Check privacy compliance

### 4. Production Deployment

Before releasing:
1. ✅ Run all 4 agents to verify
2. ✅ Test with real CloudX app key
3. ✅ Verify privacy compliance
4. ✅ Test on multiple iOS versions
5. ✅ Submit to App Store

---

## Support & Resources

### Documentation
- [Integration Guide](./INTEGRATION_GUIDE.md) - Comprehensive integration examples
- [Orchestration Guide](./ORCHESTRATION.md) - Multi-agent workflows
- [iOS SDK Documentation](https://github.com/cloudx-io/cloudx-ios)

### Getting Help
- **GitHub Issues**: [cloudx-sdk-agents/issues](https://github.com/cloudx-io/cloudx-sdk-agents/issues)
- **Email Support**: mobile@cloudx.io
- **SDK Issues**: [cloudx-ios/issues](https://github.com/cloudx-io/cloudx-ios/issues)

### CloudX Dashboard
- Manage placements
- View analytics
- Configure ad settings
- Get your app key

---

## FAQ

### Do I need to know Objective-C to use these agents?

No! Agents support both Objective-C and Swift. Specify your preference or let the agent detect your project language.

### Will this work with my existing ad code?

Yes! Agents auto-detect AdMob or AppLovin and implement fallback logic to preserve your existing setup.

### What iOS versions are supported?

CloudX iOS SDK requires **iOS 14.0+**. Agents will configure this automatically.

### Can I use multiple ad networks?

Yes! CloudX works as primary with AdMob or AppLovin as fallback. Both can operate simultaneously.

### Do I need a CloudX account?

Yes. Sign up at [cloudx.io](https://cloudx.io) to get your app key and configure placements.

### How long does integration take?

With agents: **~20 minutes**
Manual integration: **4-6 hours**

### Is this free?

The agents are free to use. CloudX SDK monetization follows standard ad network pricing.

---

## What's Next?

🎯 **Ready to integrate?** Start with:
```bash
cd /path/to/your/ios/project
claude
```

Then:
```
Use @agent-cloudx-ios-integrator to integrate CloudX SDK with app key: YOUR_KEY
```

📚 **Want more details?** Read the [Integration Guide](./INTEGRATION_GUIDE.md)

🔧 **Need help?** Open an issue or email mobile@cloudx.io
