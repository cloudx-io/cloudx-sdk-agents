# CloudX Flutter Agents - Orchestration Guide

This guide explains how to use multiple agents together for complex workflows, debugging scenarios, and production deployments.

---

## Table of Contents

1. [Agent Invocation Patterns](#agent-invocation-patterns)
2. [Sequential Workflows](#sequential-workflows)
3. [Iterative Debugging](#iterative-debugging)
4. [Parallel Execution](#parallel-execution)
5. [Common Scenarios](#common-scenarios)
6. [Best Practices](#best-practices)

---

## Agent Invocation Patterns

### Explicit Invocation (Recommended)

Use the agent name directly:

```
Use cloudx-flutter-integrator to integrate CloudX SDK with app key: MY_KEY
```

**Advantages**:
- Clear and unambiguous
- Guaranteed to invoke correct agent
- Good for documentation/scripts

### Implicit Invocation (Auto-routing)

Let Claude Code route based on intent:

```
Integrate CloudX SDK into my Flutter app
```

Claude Code will automatically route to `cloudx-flutter-integrator` based on the description in agent frontmatter.

**Advantages**:
- Natural language
- Convenient for users
- Works well for common tasks

### When to Use Each

**Use explicit** when:
- Writing documentation/guides
- Creating scripts/automation
- You want guaranteed behavior
- Multiple agents could match intent

**Use implicit** when:
- Quick ad-hoc tasks
- You trust the routing
- The intent is very clear

---

## Sequential Workflows

### Workflow 1: Complete First-Time Integration

**Scenario**: Integrating CloudX into a new or existing Flutter app

```
1. Use cloudx-flutter-integrator to integrate CloudX SDK with app key: YOUR_KEY
2. Use cloudx-flutter-auditor to verify the integration
3. Use cloudx-flutter-build-verifier to build the project
4. Use cloudx-flutter-privacy-checker to validate privacy compliance
```

**Expected outcome**:
- ✅ CloudX integrated (with or without fallback)
- ✅ Integration validated
- ✅ Builds pass
- ✅ Privacy compliant
- ✅ Ready for testing

**Timeline**: ~5-10 minutes

---

### Workflow 2: Quick Integration + Validation

**Scenario**: Fast integration with basic validation

```
1. Use cloudx-flutter-integrator to integrate CloudX SDK
2. Use cloudx-flutter-build-verifier to verify it compiles
```

**Expected outcome**:
- ✅ CloudX integrated
- ✅ Code compiles
- ⏭️ Skip auditing and privacy (do later)

**Timeline**: ~3-5 minutes

---

### Workflow 3: Pre-Production Checklist

**Scenario**: Final checks before deploying to production

```
1. Use cloudx-flutter-auditor to verify integration correctness
2. Use cloudx-flutter-build-verifier to run builds
3. Use cloudx-flutter-privacy-checker to validate compliance
```

**Expected outcome**:
- ✅ All validation passes
- ✅ No critical issues
- ✅ Ready for production

**Timeline**: ~2-3 minutes

---

## Iterative Debugging

### Scenario 1: Build Failures

**Problem**: Integration complete but build fails

**Workflow**:
```
1. Use cloudx-flutter-build-verifier to diagnose the issue
   [Agent reports specific errors with file:line references]

2. [Manually fix errors based on agent's recommendations]

3. Use cloudx-flutter-build-verifier to verify fixes
   [Agent confirms builds now pass]
```

**Example dialogue**:
```
You: Use cloudx-flutter-build-verifier to build my project

Agent: ❌ Build failed with 3 errors:
1. lib/main.dart:15 - Missing import 'package:cloudx_flutter/cloudx.dart'
2. lib/screens/home.dart:42 - Undefined name 'CloudXBannerView'
3. pubspec.yaml:12 - cloudx_flutter dependency missing

Fixes:
1. Add import statement
2. Add cloudx_flutter: ^0.1.2 to pubspec.yaml
3. Run flutter pub get

You: [Fix errors manually]

You: Use cloudx-flutter-build-verifier to verify fixes

Agent: ✅ All builds pass! Ready for testing.
```

---

### Scenario 2: Fallback Not Working

**Problem**: CloudX integrated but fallback doesn't trigger

**Workflow**:
```
1. Use cloudx-flutter-auditor to check fallback logic
   [Agent identifies missing fallback trigger in onAdLoadFailed]

2. [Fix the specific issue]

3. Use cloudx-flutter-auditor to re-verify
   [Agent confirms fallback now works]

4. Test with airplane mode to verify fallback manually
```

**Example dialogue**:
```
You: Use cloudx-flutter-auditor to check my AdMob fallback

Agent: ⚠️ Fallback validation FAILED

Issues found:
1. lib/screens/home.dart:45 - CloudXAdViewListener has onAdLoadFailed but no fallback code inside
2. lib/screens/game.dart:78 - _loadAdMobInterstitial() method exists but never called

Fix:
Add fallback trigger in onAdLoadFailed callback:
onAdLoadFailed: (error) {
  _loadAdMobBanner();  // ADD THIS
}

You: [Fix the callback]

You: Use cloudx-flutter-auditor to verify

Agent: ✅ Fallback paths validated! All checks pass.
```

---

### Scenario 3: Privacy Non-Compliance

**Problem**: App targets California users but missing CCPA

**Workflow**:
```
1. Use cloudx-flutter-privacy-checker to audit privacy
   [Agent identifies missing CCPA implementation]

2. [Add CCPA privacy API calls]

3. Use cloudx-flutter-privacy-checker to re-check
   [Agent confirms compliance]
```

**Example dialogue**:
```
You: Use cloudx-flutter-privacy-checker to validate privacy

Agent: ⚠️ Privacy compliance: PARTIAL

Issues:
- ❌ CCPA: Not implemented (required for California users)
- ✅ GPP: Implemented correctly
- ✅ COPPA: Not needed (app not child-directed)

Recommendation:
Add CCPA consent:
await CloudX.setCCPAPrivacyString('1YNN');

You: [Add CCPA code]

You: Use cloudx-flutter-privacy-checker to re-validate

Agent: ✅ Privacy compliance: PASS
All regulations properly implemented.
```

---

## Parallel Execution

**Note**: Claude Code agents run sequentially by default, but you can launch multiple tasks in a single message for faster execution.

### Scenario: Validate Everything at Once

```
Run these validations in parallel:
1. Use cloudx-flutter-auditor to verify integration
2. Use cloudx-flutter-build-verifier to build the project
3. Use cloudx-flutter-privacy-checker to check compliance
```

**Advantages**:
- Faster overall execution
- Get all results at once
- Efficient for independent checks

**When to use**:
- Validation-only workflows (no changes being made)
- Final pre-production checks
- CI/CD pipelines

**When NOT to use**:
- When agents depend on each other
- When making code changes
- When debugging specific issues

---

## Common Scenarios

### Scenario 1: Greenfield Project (No Existing Ad SDK)

**Goal**: Clean CloudX-only integration

**Workflow**:
```
1. Use cloudx-flutter-integrator to integrate CloudX SDK
   [Agent detects no existing ad SDK, implements CloudX-only]

2. Use cloudx-flutter-build-verifier to verify builds
   [Agent confirms compilation success]

3. flutter run
   [Manual testing]
```

**Result**:
- Simple, clean integration
- No fallback complexity
- Ready to monetize

---

### Scenario 2: Migrating from AdMob

**Goal**: Add CloudX as primary, keep AdMob as fallback

**Workflow**:
```
1. Use cloudx-flutter-integrator to integrate CloudX SDK
   [Agent detects google_mobile_ads, implements first-look with fallback]

2. Use cloudx-flutter-auditor to verify AdMob fallback intact
   [Agent validates fallback paths work correctly]

3. Use cloudx-flutter-build-verifier to build
   [Agent confirms builds pass]

4. Test fallback with airplane mode
   [Manual testing]
```

**Result**:
- CloudX primary, AdMob fallback
- Existing ad revenue protected
- Smooth migration path

---

### Scenario 3: Adding Privacy Compliance

**Goal**: Ensure app complies with CCPA/COPPA/GPP

**Workflow**:
```
1. Use cloudx-flutter-privacy-checker to audit current state
   [Agent identifies missing privacy implementations]

2. [Implement missing privacy APIs based on agent recommendations]

3. Use cloudx-flutter-privacy-checker to re-validate
   [Agent confirms compliance]
```

**Result**:
- Fully compliant with regulations
- Ready for California/EU users
- Child-safe if applicable

---

### Scenario 4: Pre-Production Deployment

**Goal**: Final validation before releasing to production

**Workflow**:
```
1. Disable debug logging:
   [Remove CloudX.setLoggingEnabled(true) from main.dart]

2. Set production environment:
   [Change CloudX.setEnvironment('production')]

3. Use cloudx-flutter-auditor to validate
4. Use cloudx-flutter-build-verifier to build release
5. Use cloudx-flutter-privacy-checker for final compliance check

6. flutter build apk --release
7. flutter build appbundle --release
```

**Result**:
- Production-ready build
- All validations pass
- Ready for Play Store / App Store

---

### Scenario 5: Troubleshooting Failed Integration

**Goal**: Fix broken integration after manual changes

**Workflow**:
```
1. Use cloudx-flutter-auditor to identify issues
   [Agent pinpoints exact problems with file:line references]

2. [Fix identified issues]

3. Use cloudx-flutter-build-verifier to verify fixes compile
   [Agent checks builds pass]

4. Use cloudx-flutter-auditor to re-verify
   [Agent confirms all issues resolved]
```

**Result**:
- Issues identified and fixed
- Integration working correctly
- Ready for testing

---

## Best Practices

### 1. Always Audit After Integration

**Do**:
```
1. Use cloudx-flutter-integrator to integrate CloudX SDK
2. Use cloudx-flutter-auditor to verify
```

**Why**: Catches integration issues immediately

---

### 2. Build Verification Before Testing

**Do**:
```
1. [Make code changes]
2. Use cloudx-flutter-build-verifier to verify
3. flutter run
```

**Why**: Catches compilation errors before running

---

### 3. Privacy Check Before Production

**Do**:
```
1. Use cloudx-flutter-privacy-checker to audit
2. [Fix any issues]
3. Deploy
```

**Why**: Avoids compliance issues in production

---

### 4. Use Iterative Workflows for Debugging

**Do**:
```
1. Use agent to identify issue
2. Fix the specific issue
3. Use agent to verify fix
4. Repeat if needed
```

**Why**: Systematic approach catches all issues

---

### 5. Document Your Workflow

Keep a checklist for your team:

```markdown
## Our CloudX Integration Workflow

### Initial Integration
1. Use cloudx-flutter-integrator with app key
2. Use cloudx-flutter-auditor to verify
3. Use cloudx-flutter-build-verifier to build
4. Manual testing on Android/iOS

### Pre-Production
1. Use cloudx-flutter-auditor for final check
2. Use cloudx-flutter-privacy-checker for compliance
3. Disable logging
4. Set production environment
5. Build release APK/AAB
6. Submit to stores

### Debugging
1. Use cloudx-flutter-auditor to identify issue
2. Fix based on recommendations
3. Use cloudx-flutter-build-verifier to verify
4. Repeat until resolved
```

---

## Agent Capabilities Matrix

| Agent | Reads Code | Writes Code | Runs Builds | Validates | Best For |
|-------|-----------|-------------|-------------|-----------|----------|
| **integrator** | ✅ | ✅ | ❌ | ❌ | Initial integration |
| **auditor** | ✅ | ❌ | ❌ | ✅ | Verification, debugging |
| **build-verifier** | ✅ | ❌ | ✅ | ✅ | Compilation checks |
| **privacy-checker** | ✅ | ❌ | ❌ | ✅ | Compliance audits |

---

## Common Questions

### Q: Can I run agents in parallel?

**A**: You can request parallel execution in a single message:
```
Run these in parallel:
1. Use cloudx-flutter-auditor
2. Use cloudx-flutter-build-verifier
3. Use cloudx-flutter-privacy-checker
```

But they'll still run sequentially. True parallel execution depends on Claude Code's implementation.

---

### Q: Which agent should I use first?

**A**: Always start with **cloudx-flutter-integrator** for initial integration. Then use other agents for validation.

---

### Q: How often should I run auditor?

**A**:
- After initial integration
- After manual code changes
- Before production deployment
- When debugging issues

---

### Q: Do I need to run all agents every time?

**A**: No. Use what you need:
- **Quick integration**: integrator + build-verifier
- **Production deployment**: auditor + privacy-checker
- **Debugging**: auditor only
- **Full workflow**: All 4 agents

---

### Q: What if an agent fails?

**A**:
1. Read the agent's error message carefully
2. Follow the fix recommendations
3. Make the suggested changes
4. Re-run the agent to verify

Agents provide actionable guidance with file:line references.

---

## Workflow Templates

### Template 1: First-Time Setup

```bash
cd your-flutter-project
claude
```

```
Use cloudx-flutter-integrator to integrate CloudX SDK with app key: YOUR_KEY
Use cloudx-flutter-auditor to verify the integration
Use cloudx-flutter-build-verifier to build the project
Use cloudx-flutter-privacy-checker to validate compliance
```

---

### Template 2: Quick Fix

```
Use cloudx-flutter-auditor to identify the issue
[Fix based on recommendations]
Use cloudx-flutter-build-verifier to verify fixes compile
```

---

### Template 3: Pre-Production Checklist

```
Use cloudx-flutter-auditor for final validation
Use cloudx-flutter-privacy-checker for compliance
[Disable logging, set production environment]
Use cloudx-flutter-build-verifier to build release
```

---

## Next Steps

1. **Practice** the workflows in a test project
2. **Customize** workflows for your team's needs
3. **Document** your standard procedures
4. **Share** knowledge with your team

---

## Resources

- [Setup Guide](./SETUP.md) - Installation and basics
- [Integration Guide](./INTEGRATION_GUIDE.md) - Detailed code examples
- [Agent Issues](https://github.com/cloudx-io/cloudx-sdk-agents/issues) - Report problems

---

**Happy orchestrating!** 🎵
