# CloudX iOS Agent Orchestration Guide

This guide explains how to coordinate multiple CloudX iOS agents for complete SDK integration, validation, and compliance checking.

## Table of Contents

- [Overview](#overview)
- [Agent Roles](#agent-roles)
- [Orchestration Patterns](#orchestration-patterns)
- [Common Workflows](#common-workflows)
- [Sequential vs Parallel Execution](#sequential-vs-parallel-execution)
- [Error Handling & Recovery](#error-handling--recovery)
- [Best Practices](#best-practices)
- [Troubleshooting Orchestration](#troubleshooting-orchestration)

---

## Overview

CloudX provides 4 specialized iOS agents that work together to automate SDK integration:

```
┌─────────────────────────────────────────────────────────┐
│                    User / Main Agent                     │
└────────────────────┬────────────────────────────────────┘
                     │
          ┌──────────┼──────────┬──────────┐
          │          │          │          │
          ▼          ▼          ▼          ▼
    ┌─────────┐ ┌────────┐ ┌────────┐ ┌─────────┐
    │Integrator│ │Auditor │ │Builder │ │Privacy  │
    └─────────┘ └────────┘ └────────┘ └─────────┘
```

**Key Principle**: Each agent has a specific role and can be invoked independently or as part of a coordinated workflow.

---

## Agent Roles

### 1. @agent-cloudx-ios-integrator

**Role**: Implementation

**When to Use**:
- First-time CloudX SDK integration
- Adding CloudX to existing ad setup (AdMob/AppLovin)
- Migrating from standalone AdMob/AppLovin to CloudX first-look
- Updating integration patterns

**What It Does**:
- Detects project type (CocoaPods, SPM, Xcode)
- Detects existing ad SDKs (AdMob, AppLovin)
- Adds CloudX SDK dependency
- Implements initialization code (with ATT)
- Creates ad loading code with delegates
- Implements fallback logic (if applicable)
- Provides both Objective-C and Swift examples

**Tools**: Read, Write, Edit, Grep, Glob, Bash

**Model**: Sonnet (complex implementation tasks)

### 2. @agent-cloudx-ios-auditor

**Role**: Validation

**When to Use**:
- After integrator completes implementation
- Before committing code changes
- To verify fallback paths remain intact
- When debugging integration issues
- During code review

**What It Does**:
- Validates CloudX SDK initialization
- Checks ad loading implementation
- Verifies delegate methods exist
- Audits fallback logic (AdMob/AppLovin)
- Ensures privacy configuration present
- Generates detailed audit report

**Tools**: Read, Grep, Glob (read-only)

**Model**: Haiku (fast validation)

### 3. @agent-cloudx-ios-build-verifier

**Role**: Testing

**When to Use**:
- After code changes
- Before git commit
- When fixing compilation errors
- During CI/CD pipeline
- After SDK version updates

**What It Does**:
- Detects project type (CocoaPods/SPM/Xcode)
- Runs xcodebuild with correct parameters
- Parses build output for errors/warnings
- Provides file:line references
- Suggests fixes for common CloudX errors
- Verifies framework linking

**Tools**: Bash, Read

**Model**: Haiku (build tasks are fast)

### 4. @agent-cloudx-ios-privacy-checker

**Role**: Compliance

**When to Use**:
- Before production deployment
- After implementing privacy configuration
- When adding GDPR/CCPA/COPPA support
- During privacy audit
- Before App Store submission

**What It Does**:
- Validates CloudX privacy APIs
- Checks ATT (App Tracking Transparency) implementation
- Verifies Info.plist privacy declarations
- Ensures fallback SDKs receive privacy signals
- Validates GDPR consent flow
- Checks CCPA and COPPA compliance

**Tools**: Read, Grep, Glob (read-only)

**Model**: Haiku (compliance checks are fast)

---

## Orchestration Patterns

### Pattern 1: Linear Sequential (Most Common)

**Use Case**: Complete integration from scratch

```
Integrator → Auditor → Build Verifier → Privacy Checker
```

**Example**:
```
1. Use @agent-cloudx-ios-integrator to integrate CloudX SDK with app key: YOUR_KEY

2. Use @agent-cloudx-ios-auditor to verify my CloudX integration

3. Use @agent-cloudx-ios-build-verifier to build my project

4. Use @agent-cloudx-ios-privacy-checker to validate privacy compliance
```

**Why Sequential**: Each agent depends on the previous agent's output.

### Pattern 2: Iterative with Feedback Loop

**Use Case**: Fixing integration issues

```
Integrator → Build Verifier → [FAIL] → Integrator (fix) → Build Verifier → [PASS]
     │                                                            │
     └────────────────────────────────────────────────────────────┘
```

**Example**:
```
1. Use @agent-cloudx-ios-integrator to integrate CloudX SDK

2. Use @agent-cloudx-ios-build-verifier to build

   → Build fails with "Module 'CloudXCore' not found"

3. Use @agent-cloudx-ios-integrator to fix the module import error

4. Use @agent-cloudx-ios-build-verifier to build

   → Build succeeds ✅
```

### Pattern 3: Parallel Validation (Advanced)

**Use Case**: Fast validation without write operations

```
        ┌─────────────┐
        │  Completed  │
        │ Integration │
        └──────┬──────┘
               │
       ┌───────┴───────┐
       │               │
       ▼               ▼
   Auditor        Privacy Checker
   (read-only)    (read-only)
```

**Example**:
```
After integration is complete, run both validation agents in parallel:

Use @agent-cloudx-ios-auditor and @agent-cloudx-ios-privacy-checker to validate my integration
```

**Why Parallel**: Both agents are read-only and don't conflict.

### Pattern 4: Pre-Commit Verification

**Use Case**: Ensure code quality before committing

```
Code Changes → Build Verifier → Auditor → Privacy Checker → Git Commit
```

**Example**:
```
1. Use @agent-cloudx-ios-build-verifier to verify build

2. Use @agent-cloudx-ios-auditor to check integration

3. Use @agent-cloudx-ios-privacy-checker to validate compliance

   → All pass ✅

4. Git commit and push
```

---

## Common Workflows

### Workflow 1: Greenfield Integration (No Existing Ad SDK)

**Scenario**: New iOS app, no existing ad code

**Steps**:
```
1. Navigate to iOS project directory
   cd /path/to/ios/project

2. Launch Claude Code
   claude

3. Invoke integrator (CloudX-only mode)
   Use @agent-cloudx-ios-integrator to integrate CloudX SDK with app key: YOUR_KEY

4. Install dependencies
   pod install  # or Xcode will auto-resolve SPM

5. Verify integration
   Use @agent-cloudx-ios-auditor to verify my CloudX integration

6. Run build
   Use @agent-cloudx-ios-build-verifier to build my project

7. Check privacy compliance
   Use @agent-cloudx-ios-privacy-checker to validate privacy settings

8. Test in Xcode
   - Open .xcworkspace (CocoaPods) or .xcodeproj
   - Build and run (⌘R)
   - Test ad loading
```

**Expected Outcome**:
- ✅ CloudX SDK integrated
- ✅ Initialization code added to AppDelegate
- ✅ Ad loading examples provided
- ✅ Privacy configuration implemented
- ✅ Build succeeds
- ✅ ATT properly configured

### Workflow 2: Migration from AdMob (First-Look with Fallback)

**Scenario**: Existing iOS app with AdMob

**Steps**:
```
1. Navigate to iOS project
   cd /path/to/ios/project

2. Launch Claude Code
   claude

3. Invoke integrator with AdMob fallback
   Use @agent-cloudx-ios-integrator to integrate CloudX SDK with AdMob fallback using app key: YOUR_KEY

4. Install dependencies
   pod install

5. Verify fallback logic
   Use @agent-cloudx-ios-auditor to verify my CloudX integration with AdMob fallback

6. Build project
   Use @agent-cloudx-ios-build-verifier to build my project

7. Check privacy for both SDKs
   Use @agent-cloudx-ios-privacy-checker to ensure both CloudX and AdMob receive privacy signals

8. Test in Xcode
   - Test CloudX ad loading
   - Test AdMob fallback (simulate CloudX failure)
```

**Expected Outcome**:
- ✅ CloudX SDK added as primary
- ✅ AdMob remains as fallback
- ✅ Fallback triggers in `bannerDidFailToLoad` callbacks
- ✅ Both SDKs receive privacy signals
- ✅ Build succeeds
- ✅ AdMob fallback path validated

### Workflow 3: Fixing Build Errors

**Scenario**: Build fails after integration

**Steps**:
```
1. Run build verifier to diagnose
   Use @agent-cloudx-ios-build-verifier to build my project

   → Build fails with errors

2. Review build report
   - Note file:line references
   - Check suggested fixes

3. Apply fixes manually or invoke integrator
   Use @agent-cloudx-ios-integrator to fix the "Module 'CloudXCore' not found" error

4. Re-run build
   Use @agent-cloudx-ios-build-verifier to build

   → Build succeeds ✅

5. Verify integration still correct
   Use @agent-cloudx-ios-auditor to verify
```

**Common Build Errors**:
- Module 'CloudXCore' not found → Run pod install
- Missing delegate methods → Implement required protocols
- Wrong API usage → Update to current API
- Privacy manifest issues → Add Info.plist entries

### Workflow 4: Privacy Compliance Audit

**Scenario**: Pre-production privacy check

**Steps**:
```
1. Run privacy checker
   Use @agent-cloudx-ios-privacy-checker to validate privacy compliance

2. Review privacy report
   - Check ATT implementation
   - Verify GDPR consent flow
   - Validate CCPA configuration
   - Check COPPA settings

3. Fix missing privacy configurations
   Use @agent-cloudx-ios-integrator to add CCPA privacy string configuration

4. Re-run privacy checker
   Use @agent-cloudx-ios-privacy-checker to validate

   → All privacy checks pass ✅

5. Document privacy configuration
   - Update privacy policy
   - Add user consent UI
```

**Privacy Checklist**:
- ✅ NSUserTrackingUsageDescription in Info.plist
- ✅ ATT request before SDK initialization
- ✅ CCPA privacy string configured
- ✅ GDPR consent flow (if applicable)
- ✅ COPPA flag for child-directed apps
- ✅ Fallback SDKs receive privacy signals

### Workflow 5: Multi-Format Integration

**Scenario**: Integrate multiple ad formats

**Steps**:
```
1. Start with banner ads
   Use @agent-cloudx-ios-integrator to integrate CloudX banner ads with app key: YOUR_KEY

2. Verify banner implementation
   Use @agent-cloudx-ios-auditor to check banner integration

3. Add interstitial ads
   Use @agent-cloudx-ios-integrator to add CloudX interstitial ads

4. Add rewarded ads
   Use @agent-cloudx-ios-integrator to add CloudX rewarded ads

5. Build and verify all formats
   Use @agent-cloudx-ios-build-verifier to build
   Use @agent-cloudx-ios-auditor to verify all ad formats

6. Test each format in Xcode
   - Banner auto-loads on creation
   - Interstitial: load, wait, show(from:)
   - Rewarded: load, wait, show(from:), handle reward
```

---

## Sequential vs Parallel Execution

### Sequential Execution (Required for Dependencies)

**When to Use**:
- One agent's output is needed by the next agent
- Write operations that modify files
- Building on previous agent's changes

**Examples**:

```
✅ CORRECT (Sequential):
1. Integrator (writes code)
2. Build Verifier (tests integrator's code)
3. Auditor (validates integrator's code)
```

```
❌ INCORRECT (Parallel):
Integrator + Build Verifier at same time
→ Build verifier may test before integrator finishes writing
```

### Parallel Execution (Possible for Independent Tasks)

**When to Use**:
- Both agents are read-only
- No dependencies between agents
- Independent validation tasks

**Examples**:

```
✅ CORRECT (Parallel):
Auditor + Privacy Checker
→ Both read-only, no conflicts
```

```
✅ CORRECT (Parallel):
Build Verifier + Privacy Checker
→ Both can run independently on existing code
```

**How to Execute in Parallel**:
```
Use @agent-cloudx-ios-auditor and @agent-cloudx-ios-privacy-checker to validate my integration
```

Claude Code will execute both agents concurrently.

---

## Error Handling & Recovery

### Build Failures

**Scenario**: Build verifier reports errors

**Recovery Steps**:
1. Read build report carefully
2. Note file:line references
3. Check suggested fix
4. Apply fix (manually or via integrator)
5. Re-run build verifier
6. Repeat until build succeeds

**Example**:
```
Build fails: "No such module 'CloudXCore'" at ViewController.swift:1:8

Fix: Run pod install
Verify: Use @agent-cloudx-ios-build-verifier to build
Result: ✅ Build succeeds
```

### Audit Failures

**Scenario**: Auditor finds missing implementation

**Recovery Steps**:
1. Review audit report
2. Identify missing components
3. Invoke integrator to add missing code
4. Re-run auditor
5. Proceed to build verification

**Example**:
```
Audit fails: "Missing fallback logic in bannerDidFailToLoad"

Fix: Use @agent-cloudx-ios-integrator to add AdMob fallback to banner implementation
Verify: Use @agent-cloudx-ios-auditor to verify
Result: ✅ Fallback logic validated
```

### Privacy Compliance Failures

**Scenario**: Privacy checker finds missing configuration

**Recovery Steps**:
1. Review privacy report
2. Identify missing privacy configurations
3. Add required privacy code
4. Re-run privacy checker
5. Proceed to production

**Example**:
```
Privacy check fails: "NSUserTrackingUsageDescription missing from Info.plist"

Fix: Use @agent-cloudx-ios-integrator to add ATT description to Info.plist
Verify: Use @agent-cloudx-ios-privacy-checker to validate
Result: ✅ ATT compliance validated
```

### Integration Conflicts

**Scenario**: Multiple ad SDKs conflict

**Recovery Steps**:
1. Use auditor to identify conflicts
2. Review SDK versions in Podfile/Package.swift
3. Update to compatible versions
4. Re-run build verifier
5. Test runtime behavior

**Example**:
```
Conflict: AdMob SDK v10.0.0 conflicts with CloudX SDK v1.2.0

Fix: Update Podfile to AdMob v11.0.0 (compatible)
      pod install
Verify: Use @agent-cloudx-ios-build-verifier to build
Result: ✅ Build succeeds
```

---

## Best Practices

### 1. Always Start with Integrator

The integrator detects your project structure and existing ad SDKs. Don't skip this step.

```
❌ BAD:
Manually add CloudX SDK → Build fails → Confused

✅ GOOD:
Use @agent-cloudx-ios-integrator → Auto-detects project type → Correct setup
```

### 2. Run Auditor After Integration

Catch issues early before building.

```
✅ RECOMMENDED:
Integrator → Auditor → Build Verifier

❌ RISKY:
Integrator → Build Verifier (skip auditor)
→ May miss logical errors that still compile
```

### 3. Run Build Verifier Before Committing

Don't commit broken code.

```
✅ WORKFLOW:
Code changes → Build Verifier → [PASS] → Git commit

❌ AVOID:
Code changes → Git commit → Build fails in CI
```

### 4. Run Privacy Checker Before Production

Validate compliance before App Store submission.

```
✅ PRE-LAUNCH:
Privacy Checker → [PASS] → Deploy to App Store

❌ RISKY:
Deploy without privacy check → App Store rejection
```

### 5. Use Explicit Agent Invocations

Be specific about which agent you want.

```
✅ EXPLICIT:
Use @agent-cloudx-ios-integrator to integrate CloudX SDK

❌ VAGUE:
Integrate CloudX SDK
→ Claude Code may not route to correct agent
```

### 6. Provide Context

Give agents relevant information.

```
✅ WITH CONTEXT:
Use @agent-cloudx-ios-integrator to integrate CloudX SDK with AdMob fallback using app key: abc123

❌ NO CONTEXT:
Use @agent-cloudx-ios-integrator
→ Agent has to ask for details
```

### 7. Review Agent Output

Don't blindly trust agent changes.

```
✅ REVIEW:
1. Agent makes changes
2. Review diff carefully
3. Understand what changed
4. Test manually

❌ BLIND TRUST:
1. Agent makes changes
2. Git add .
3. Git commit
→ May introduce bugs
```

### 8. Keep Agents Up-to-Date

Ensure agents match SDK version.

```
✅ CHECK VERSIONS:
# Check agent version
cat ~/.claude/agents/cloudx-ios-integrator.md | grep "SDK v"

# Update agents if needed
bash <(curl -fsSL https://raw.githubusercontent.com/cloudx-io/cloudx-sdk-agents/main/scripts/install.sh) --platform=ios
```

---

## Troubleshooting Orchestration

### Problem: Agents Not Found

**Symptom**: "Agent @agent-cloudx-ios-integrator not found"

**Cause**: Agents not installed

**Fix**:
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/cloudx-io/cloudx-sdk-agents/main/scripts/install.sh) --platform=ios
```

**Verify**:
```bash
ls ~/.claude/agents/ | grep cloudx-ios
```

### Problem: Wrong Agent Invoked

**Symptom**: Unexpected agent behavior

**Cause**: Ambiguous invocation, auto-routing picked wrong agent

**Fix**: Use explicit agent names
```
❌ Ambiguous: Check my CloudX integration
✅ Explicit: Use @agent-cloudx-ios-auditor to verify my CloudX integration
```

### Problem: Agent Stuck or Hanging

**Symptom**: Agent doesn't respond

**Cause**: Long-running operation (build, pod install)

**Fix**: Be patient, or check background processes
```bash
# Check if xcodebuild is running
ps aux | grep xcodebuild

# Check if pod install is running
ps aux | grep pod
```

### Problem: Conflicting Agent Changes

**Symptom**: Agent A's changes conflict with Agent B's changes

**Cause**: Concurrent execution on overlapping files

**Fix**: Run agents sequentially
```
❌ CONFLICT:
Integrator (writes AppDelegate) + Auditor (reads AppDelegate) in parallel

✅ FIXED:
Integrator → Auditor (sequential)
```

### Problem: Outdated Agent Knowledge

**Symptom**: Agent uses old API patterns

**Cause**: Agents out of sync with SDK version

**Fix**: Update agents
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/cloudx-io/cloudx-sdk-agents/main/scripts/install.sh) --platform=ios
```

**Check SDK version**:
```bash
# In your iOS project
cat Podfile.lock | grep CloudXCore
# or
cat Package.resolved | grep cloudx-ios
```

### Problem: Privacy Checker False Positives

**Symptom**: Privacy checker reports issues that don't apply

**Cause**: Custom privacy implementation not recognized

**Fix**: Review privacy report, ignore false positives
```
Privacy Checker says: "No CCPA configuration found"
Your code: Custom CCPA UI in Settings

Action: Acknowledge and document your custom implementation
```

---

## Advanced Orchestration

### CI/CD Integration

**Example GitHub Actions workflow**:

```yaml
name: CloudX iOS Integration Check

on: [pull_request]

jobs:
  validate:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3

      - name: Install CloudX agents
        run: |
          bash <(curl -fsSL https://raw.githubusercontent.com/cloudx-io/cloudx-sdk-agents/main/scripts/install.sh) --platform=ios

      - name: Install dependencies
        run: pod install

      - name: Build project
        run: |
          claude --non-interactive "Use @agent-cloudx-ios-build-verifier to build my project"

      - name: Audit integration
        run: |
          claude --non-interactive "Use @agent-cloudx-ios-auditor to verify integration"

      - name: Check privacy
        run: |
          claude --non-interactive "Use @agent-cloudx-ios-privacy-checker to validate compliance"
```

### Custom Orchestration Scripts

**Example bash script**:

```bash
#!/bin/bash
# cloudx-ios-validate.sh

set -e

echo "🚀 Starting CloudX iOS validation..."

# 1. Build
echo "📦 Building project..."
claude --non-interactive "Use @agent-cloudx-ios-build-verifier to build"

# 2. Audit
echo "🔍 Auditing integration..."
claude --non-interactive "Use @agent-cloudx-ios-auditor to verify"

# 3. Privacy check
echo "🔒 Checking privacy compliance..."
claude --non-interactive "Use @agent-cloudx-ios-privacy-checker to validate"

echo "✅ All checks passed!"
```

**Usage**:
```bash
chmod +x cloudx-ios-validate.sh
./cloudx-ios-validate.sh
```

---

## Summary

**Key Takeaways**:

1. **Start with Integrator** - Detects your setup and implements correctly
2. **Validate with Auditor** - Catches logical errors early
3. **Test with Build Verifier** - Ensures code compiles
4. **Comply with Privacy Checker** - Validates GDPR/CCPA/ATT before production
5. **Use Sequential Execution** - When agents depend on each other
6. **Use Parallel Execution** - For independent read-only validation
7. **Handle Errors Iteratively** - Fix, verify, repeat until success
8. **Review Agent Changes** - Don't blindly commit

**Recommended Full Workflow**:
```
1. @agent-cloudx-ios-integrator (implement)
2. pod install (or Xcode resolves SPM)
3. @agent-cloudx-ios-auditor (validate logic)
4. @agent-cloudx-ios-build-verifier (test build)
5. @agent-cloudx-ios-privacy-checker (check compliance)
6. Manual testing in Xcode
7. Git commit and push
```

**Next Steps**:
- Read [SETUP.md](./SETUP.md) for installation
- Read [INTEGRATION_GUIDE.md](./INTEGRATION_GUIDE.md) for code examples
- Start integrating CloudX SDK with confidence

---

**Questions or Issues?**
- GitHub Issues: [cloudx-sdk-agents/issues](https://github.com/cloudx-io/cloudx-sdk-agents/issues)
- Email: mobile@cloudx.io
