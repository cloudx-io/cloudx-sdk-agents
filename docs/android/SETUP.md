# CloudX SDK Integration with Claude Code Agents

Automate your CloudX SDK integration using AI-powered Claude Code agents. This guide will help you set up and use CloudX's specialized integration agents to integrate the SDK in minutes instead of hours.

## What Are Claude Code Agents?

Claude Code agents are specialized AI assistants that automate complex integration tasks. CloudX provides 4 specialized agents that:

- **cloudx-android-integrator**: Implements CloudX SDK first look with fallback to AdMob/AppLovin
- **cloudx-android-auditor**: Validates that existing ad fallback paths remain intact
- **cloudx-android-build-verifier**: Runs Gradle builds and catches compilation errors
- **cloudx-android-privacy-checker**: Ensures GDPR, CCPA, and COPPA compliance

## Benefits

✅ **Fast Integration**: 20 minutes vs 4-6 hours manual work
✅ **Automatic Fallback**: Preserves your existing AdMob/AppLovin setup
✅ **Privacy Compliant**: Validates GDPR/CCPA handling automatically
✅ **Build Verified**: Catches errors before runtime
✅ **Best Practices**: Implements proper initialization order and ad loading patterns

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

**Windows (PowerShell):**
```powershell
irm https://claude.ai/install.ps1 | iex
```

**Windows (CMD):**
```cmd
curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd
```

**Alternative: VS Code Extension (Beta)**
- Install from VS Code marketplace
- Search for: "Claude Code"

**Verify Installation:**
```bash
claude --version
# Should show Claude Code version
```

### 2. Get Your CloudX App Key

Sign up at [CloudX Dashboard](https://app.cloudx.io) to get:
- Your app key (e.g., `"abc123-your-app-key"`)
- Placement IDs for your ad units

### 3. Existing Android Project

You should have:
- Android project with API 21+
- Existing ad integration (AdMob, AppLovin, or none)
- Kotlin or Java codebase

---

## Installation

### Quick Install (One-Liner)

Install CloudX agents globally to your machine:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/cloudx-io/cloudexchange.android.sdk/main/install.sh)
```

This installs 4 agents to `~/.claude/agents/` and makes them available for all your projects.

### Alternative: Manual Installation

**Global Installation (Recommended):**
```bash
# Download install script
curl -fsSL https://raw.githubusercontent.com/cloudx-io/cloudexchange.android.sdk/main/install.sh -o install.sh

# Run installer
bash install.sh --global

# Verify
ls ~/.claude/agents/
```

**Local Installation (Project-Specific):**
```bash
# In your Android project directory
curl -fsSL https://raw.githubusercontent.com/cloudx-io/cloudexchange.android.sdk/main/install.sh -o install.sh

# Run installer locally
bash install.sh --local

# Verify
ls .claude/agents/
```

**Manual Download:**
```bash
# Create agents directory
mkdir -p ~/.claude/agents

# Download each agent
curl -fsSL https://raw.githubusercontent.com/cloudx-io/cloudexchange.android.sdk/main/.claude/agents/cloudx-android-integrator.md \
  -o ~/.claude/agents/cloudx-android-integrator.md
curl -fsSL https://raw.githubusercontent.com/cloudx-io/cloudexchange.android.sdk/main/.claude/agents/cloudx-android-auditor.md \
  -o ~/.claude/agents/cloudx-android-auditor.md
curl -fsSL https://raw.githubusercontent.com/cloudx-io/cloudexchange.android.sdk/main/.claude/agents/cloudx-android-build-verifier.md \
  -o ~/.claude/agents/cloudx-android-build-verifier.md
curl -fsSL https://raw.githubusercontent.com/cloudx-io/cloudexchange.android.sdk/main/.claude/agents/cloudx-android-privacy-checker.md \
  -o ~/.claude/agents/cloudx-android-privacy-checker.md
```

---

## Usage

### Full Integration Workflow

**Step 1: Navigate to Your Android Project**
```bash
cd /path/to/your/android/project
claude  # Launches Claude Code CLI
```

**Step 2: Request Integration**

Type (explicitly invoke the agent):
```
Use cloudx-android-integrator to integrate CloudX SDK with app key: YOUR_APP_KEY
```

Or be more specific:
```
Use cloudx-android-integrator to integrate CloudX SDK as primary ad network with AdMob fallback.
My app key is abc123-your-key.
Update banner and interstitial ads.
```

**Important:** Always start with `Use cloudx-android-integrator to` so Claude Code loads the correct agent.

**Step 3: Review Changes**

Claude Code will:
1. 🔍 Scan your codebase for existing ad SDKs
2. 📦 Add CloudX dependencies to build.gradle
3. 🔧 Update Application class with CloudX initialization
4. 🎯 Modify ad loading code with CloudX + fallback
5. ✅ Validate fallback paths still work
6. 🏗️ Run build to catch errors
7. 🔒 Check privacy compliance

**Step 4: Test & Deploy**
```bash
# Build and install
./gradlew installDebug

# Test CloudX ads load
# Test fallback works (enable airplane mode)
# Deploy to production
```

### Individual Agent Usage

You can also invoke agents individually:

**Integration Only:**
```
Use cloudx-android-integrator to integrate CloudX SDK with AdMob fallback
```

**Validation Only:**
```
Use cloudx-android-auditor to verify my AdMob fallback paths are correct
```

**Build Check:**
```
Use cloudx-android-build-verifier to run ./gradlew build and check for errors
```

**Privacy Audit:**
```
Use cloudx-android-privacy-checker to validate GDPR compliance
```

---

## What Gets Changed

### Files Modified

The agents will modify these files (typical integration):

**build.gradle (app module):**
```gradle
dependencies {
    // ADDED: CloudX SDK
    implementation("io.cloudx:sdk:0.5.0")
    implementation("io.cloudx:adapter-cloudx:0.5.0")

    // UNCHANGED: Your existing ad SDKs
    implementation("com.google.android.gms:play-services-ads:23.0.0")
}
```

**Application.kt / Application.java:**
```kotlin
class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()

        // ADDED: CloudX initialization (runs first)
        CloudX.initialize(
            CloudXInitializationParams(appKey = "your-key"),
            object : CloudXInitializationListener {
                override fun onInitialized() { }
                override fun onInitializationFailed(error: CloudXError) { }
            }
        )

        // UNCHANGED: Existing SDK initialization
        MobileAds.initialize(this)
    }
}
```

**Ad Loading Code (Activities/Fragments):**
```kotlin
// BEFORE: Direct AdMob
private fun loadBanner() {
    val adView = AdView(this)
    adView.loadAd(AdRequest.Builder().build())
}

// AFTER: CloudX first, AdMob fallback
private fun loadBanner() {
    val cloudXBanner = CloudX.createBanner("banner_placement")
    cloudXBanner.listener = object : CloudXAdViewListener {
        override fun onAdLoaded(ad: CloudXAd) {
            // CloudX success
            container.addView(cloudXBanner)
        }
        override fun onAdLoadFailed(error: CloudXError) {
            // Fallback to AdMob
            loadAdMobBanner()
        }
    }
    cloudXBanner.load()
}

private fun loadAdMobBanner() {
    val adView = AdView(this)
    adView.loadAd(AdRequest.Builder().build())
}
```

---

## Examples

### Example 1: New App (No Existing Ads)

```
Integrate CloudX SDK with app key: abc123.
Add banner ad to MainActivity and interstitial ad to GameOverActivity.
```

**Result:**
- CloudX SDK added
- Banner ad in MainActivity
- Interstitial ad in GameOverActivity
- Privacy compliance validated

### Example 2: Existing AdMob Integration

```
Integrate CloudX SDK with AdMob fallback.
My app key is abc123.
Keep AdMob as backup if CloudX fails.
```

**Result:**
- CloudX added as primary
- Existing AdMob code preserved
- First look logic added (CloudX → AdMob)
- All placements updated

### Example 3: Complex Integration

```
Integrate CloudX SDK:
- App key: abc123
- Update 3 banner placements
- Update 2 interstitial placements
- Fallback to AdMob
- Ensure GDPR consent passes to CloudX
```

**Result:**
- All 5 placements updated
- AdMob fallback preserved
- Privacy compliance validated
- Build verified

---

## Troubleshooting

### Agents Not Found

**Symptom:** Claude Code says "I don't have access to cloudx-android-integrator"

**Solution:**
```bash
# Verify installation
ls ~/.claude/agents/

# Should show:
# cloudx-android-integrator.md
# cloudx-android-auditor.md
# cloudx-android-build-verifier.md
# cloudx-android-privacy-checker.md

# If missing, reinstall:
bash <(curl -fsSL https://raw.githubusercontent.com/cloudx-io/cloudexchange.android.sdk/main/install.sh)
```

### Build Errors After Integration

**Symptom:** Project doesn't compile after integration

**Solution:**
```bash
# Ask Claude to fix:
Use cloudx-android-build-verifier to run ./gradlew build and fix any errors
```

Or manually:
```bash
# Clean and rebuild
./gradlew clean build

# Check logs for specific errors
```

### Fallback Not Working

**Symptom:** When CloudX fails, app shows no ads

**Solution:**
```bash
# Audit the integration:
Use cloudx-android-auditor to check if my AdMob fallback paths are correct
```

Claude will identify missing fallback logic and fix it.

### Privacy Compliance Issues

**Symptom:** Concerned about GDPR/CCPA compliance

**Solution:**
```bash
# Run privacy check:
Use cloudx-android-privacy-checker to validate GDPR and CCPA compliance
```

### Reinstall Agents

```bash
# Remove old agents
rm -rf ~/.claude/agents/cloudx-*

# Reinstall
bash <(curl -fsSL https://raw.githubusercontent.com/cloudx-io/cloudexchange.android.sdk/main/install.sh)
```

---

## Advanced Usage

### Custom Initialization Order

If you need specific initialization timing:
```
Integrate CloudX SDK with these requirements:
- Initialize CloudX after Firebase
- Initialize CloudX before ad load attempts
- Keep AdMob initialization unchanged
```

### Selective Placement Updates

Update specific ad placements only:
```
Use cloudx-android-integrator to add CloudX to MainActivity banner only,
keep other placements unchanged
```

### Review-Only Mode

Ask Claude to review without making changes:
```
Review my codebase and tell me what changes would be needed
to integrate CloudX SDK with AdMob fallback.
Don't make any changes yet.
```

---

## Time Estimates

| Task | Manual | With Agents |
|------|--------|-------------|
| Add dependencies | 5 min | Automatic |
| Implement initialization | 15 min | Automatic |
| Update ad loading (per placement) | 30 min | Automatic |
| Add fallback logic | 45 min | Automatic |
| Test & debug | 1-2 hours | 15 min |
| Privacy validation | 30 min | Automatic |
| **Total (3 placements)** | **4-6 hours** | **20 minutes** |

---

## Support & Resources

### Documentation
- **Agent Reference**: [ORCHESTRATION.md](./ORCHESTRATION.md)
- **Integration Guide**: [INTEGRATION_GUIDE.md](./INTEGRATION_GUIDE.md)
- **SDK Documentation**: [../../README.md](../../README.md)

### Getting Help
- **GitHub Issues**: [cloudx-io/cloudexchange.android.sdk/issues](https://github.com/cloudx-io/cloudexchange.android.sdk/issues)
- **Email Support**: mobile@cloudx.io
- **Claude Code Docs**: [claude.ai/code](https://claude.ai/code)

### Feedback
Found an issue with the agents? Please report:
- Agent errors or incorrect behavior
- Integration bugs
- Documentation improvements
- Feature requests

---

## FAQ

**Q: Do I need to know how to code to use these agents?**
A: Basic Android development knowledge helps, but agents handle most complexity. You should understand your app's structure.

**Q: Will this replace my existing ad setup?**
A: No! Agents preserve your existing AdMob/AppLovin as fallback. CloudX becomes the primary network.

**Q: What if I don't like the changes?**
A: You can review all changes before committing. Use git to revert if needed.

**Q: Can I use these agents without internet?**
A: Initial agent download requires internet. After installation, Claude Code can work offline (but SDK integration requires downloading dependencies).

**Q: Are these agents free?**
A: Yes, the agents are free and open source. You need a Claude Code subscription from Anthropic.

**Q: How do I update agents when the SDK changes?**
A: Rerun the install script. It will download the latest agent versions.

**Q: Can I modify the agents?**
A: Yes! Agents are markdown files you can customize. See [ORCHESTRATION.md](./ORCHESTRATION.md) for details.

---

## Next Steps

1. ✅ Install agents: `bash <(curl -fsSL https://raw.githubusercontent.com/cloudx-io/cloudexchange.android.sdk/main/install.sh)`
2. ✅ Open your Android project
3. ✅ Ask Claude: `"Integrate CloudX SDK with app key: YOUR_KEY"`
4. ✅ Review and test changes
5. ✅ Deploy to production
6. 📊 Monitor revenue in CloudX dashboard

Happy integrating! 🚀
