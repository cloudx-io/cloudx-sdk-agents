#!/bin/bash
# Validates Flutter agent documentation syntax and consistency
# For full SDK API validation, run from Flutter SDK repo with SDK source available

# Note: We do NOT use 'set -e' here because we want to collect ALL failures
# before exiting, not stop at the first error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
AGENT_DIR="$REPO_ROOT/.claude/agents/flutter"

# Flutter SDK DIR can be provided via env var or default to sibling repo
FLUTTER_SDK_DIR="${FLUTTER_SDK_DIR:-$(dirname "$REPO_ROOT")/cloudx-flutter/cloudx_flutter_sdk}"

echo "🔍 CloudX Flutter Agent Documentation Validation"
echo "==============================================="
echo ""

# Check if Flutter SDK source is available
SDK_AVAILABLE=false
if [ -d "$FLUTTER_SDK_DIR" ]; then
    echo "✅ Flutter SDK source found: $FLUTTER_SDK_DIR"
    echo "   Running full validation (agent docs + SDK API)"
    SDK_AVAILABLE=true
else
    echo "⚠️  Flutter SDK source not found at: $FLUTTER_SDK_DIR"
    echo "   Running agent doc validation only (syntax & consistency)"
    echo ""
    echo "   To validate against SDK APIs, set FLUTTER_SDK_DIR environment variable:"
    echo "   export FLUTTER_SDK_DIR=/path/to/cloudx-flutter/cloudx_flutter_sdk"
    echo ""
fi

# Track results
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNINGS=0

# Helper functions
check_pass() {
    echo -e "${GREEN}✅ PASS${NC}: $1"
    ((TOTAL_CHECKS++))
    ((PASSED_CHECKS++))
}

check_fail() {
    echo -e "${RED}❌ FAIL${NC}: $1"
    echo -e "   ${RED}→${NC} $2"
    ((TOTAL_CHECKS++))
    ((FAILED_CHECKS++))
}

check_warn() {
    echo -e "${YELLOW}⚠️  WARN${NC}: $1"
    echo -e "   ${YELLOW}→${NC} $2"
    ((WARNINGS++))
}

# 1. Check agent files exist
echo "📁 Checking Flutter Agent Files..."
if [ ! -d "$AGENT_DIR" ]; then
    check_fail "Agent directory not found" "Expected: $AGENT_DIR"
    exit 1
fi

REQUIRED_AGENTS=(
    "cloudx-flutter-integrator"
    "cloudx-flutter-auditor"
    "cloudx-flutter-build-verifier"
    "cloudx-flutter-privacy-checker"
)

for agent in "${REQUIRED_AGENTS[@]}"; do
    if [ -f "$AGENT_DIR/${agent}.md" ]; then
        check_pass "Agent file exists: ${agent}.md"
    else
        check_fail "Agent file missing: ${agent}.md" "Expected at $AGENT_DIR/${agent}.md"
    fi
done

echo ""

# 2. Check for critical Flutter SDK API references
echo "🔍 Checking Critical API References..."

# Check for CloudX class
if grep -r "CloudX\\.initialize" "$AGENT_DIR" --include="*.md" > /dev/null 2>&1; then
    check_pass "Found CloudX.initialize API"
else
    check_fail "Missing CloudX.initialize API" "Agent docs should reference CloudX.initialize()"
fi

# Check for CloudXBannerView widget
if grep -r "CloudXBannerView" "$AGENT_DIR" --include="*.md" > /dev/null 2>&1; then
    check_pass "Found CloudXBannerView widget"
else
    check_fail "Missing CloudXBannerView widget" "Agent docs should reference CloudXBannerView"
fi

# Check for CloudXMRECView widget
if grep -r "CloudXMRECView" "$AGENT_DIR" --include="*.md" > /dev/null 2>&1; then
    check_pass "Found CloudXMRECView widget"
else
    check_warn "Missing CloudXMRECView widget" "Agent docs should reference CloudXMRECView"
fi

# Check for CloudXAdViewListener
if grep -r "CloudXAdViewListener" "$AGENT_DIR" --include="*.md" > /dev/null 2>&1; then
    check_pass "Found CloudXAdViewListener"
else
    check_fail "Missing CloudXAdViewListener" "Agent docs should reference CloudXAdViewListener"
fi

# Check for CloudXInterstitialListener
if grep -r "CloudXInterstitialListener" "$AGENT_DIR" --include="*.md" > /dev/null 2>&1; then
    check_pass "Found CloudXInterstitialListener"
else
    check_fail "Missing CloudXInterstitialListener" "Agent docs should reference CloudXInterstitialListener"
fi

# Check for destroyAd lifecycle method
if grep -r "destroyAd" "$AGENT_DIR" --include="*.md" > /dev/null 2>&1; then
    check_pass "Found destroyAd() lifecycle method"
else
    check_fail "Missing destroyAd() lifecycle method" "Agent docs should emphasize destroyAd() calls"
fi

# Check for allowIosExperimental flag
if grep -r "allowIosExperimental.*true" "$AGENT_DIR" --include="*.md" > /dev/null 2>&1; then
    check_pass "Found allowIosExperimental flag"
else
    check_fail "Missing allowIosExperimental flag" "Agent docs should include allowIosExperimental: true for iOS"
fi

echo ""

# 3. Check privacy APIs
echo "🔒 Checking Privacy API References..."

if grep -r "setCCPAPrivacyString" "$AGENT_DIR" --include="*.md" > /dev/null 2>&1; then
    check_pass "Found CCPA privacy API"
else
    check_warn "Missing CCPA privacy API" "Privacy checker should reference setCCPAPrivacyString"
fi

if grep -r "setGPPString" "$AGENT_DIR" --include="*.md" > /dev/null 2>&1; then
    check_pass "Found GPP privacy API"
else
    check_warn "Missing GPP privacy API" "Privacy checker should reference setGPPString"
fi

if grep -r "setIsAgeRestrictedUser" "$AGENT_DIR" --include="*.md" > /dev/null 2>&1; then
    check_pass "Found COPPA privacy API"
else
    check_warn "Missing COPPA privacy API" "Privacy checker should reference setIsAgeRestrictedUser"
fi

echo ""

# 4. Check for common Flutter patterns
echo "📱 Checking Flutter-Specific Patterns..."

# Check for StatefulWidget pattern
if grep -r "StatefulWidget" "$AGENT_DIR" --include="*.md" > /dev/null 2>&1; then
    check_pass "Found StatefulWidget pattern"
else
    check_warn "Missing StatefulWidget pattern" "Agent docs should show StatefulWidget lifecycle"
fi

# Check for dispose() method
if grep -r "dispose()" "$AGENT_DIR" --include="*.md" > /dev/null 2>&1; then
    check_pass "Found dispose() lifecycle method"
else
    check_fail "Missing dispose() method" "Agent docs MUST emphasize dispose() for cleanup"
fi

# Check for mounted check before setState
if grep -r "mounted" "$AGENT_DIR" --include="*.md" > /dev/null 2>&1; then
    check_pass "Found mounted check pattern"
else
    check_warn "Missing mounted check" "Agent docs should show 'if (mounted)' before setState"
fi

# Check for async/await patterns
if grep -r "async.*await" "$AGENT_DIR" --include="*.md" > /dev/null 2>&1; then
    check_pass "Found async/await pattern"
else
    check_fail "Missing async/await pattern" "Agent docs MUST show async/await for CloudX APIs"
fi

# Check for Future<void> patterns
if grep -r "Future<void>" "$AGENT_DIR" --include="*.md" > /dev/null 2>&1; then
    check_pass "Found Future<void> pattern"
else
    check_warn "Missing Future<void> pattern" "Agent docs should show Future<void> for async methods"
fi

echo ""

# 5. Check for build commands
echo "🔨 Checking Build Command References..."

if grep -r "flutter pub get" "$AGENT_DIR" --include="*.md" > /dev/null 2>&1; then
    check_pass "Found flutter pub get command"
else
    check_fail "Missing flutter pub get" "Build verifier should reference 'flutter pub get'"
fi

if grep -r "flutter analyze" "$AGENT_DIR" --include="*.md" > /dev/null 2>&1; then
    check_pass "Found flutter analyze command"
else
    check_warn "Missing flutter analyze" "Build verifier should reference 'flutter analyze'"
fi

if grep -r "flutter build apk\|flutter build appbundle" "$AGENT_DIR" --include="*.md" > /dev/null 2>&1; then
    check_pass "Found Android build commands"
else
    check_fail "Missing Android build commands" "Build verifier should reference 'flutter build apk'"
fi

if grep -r "flutter build ios" "$AGENT_DIR" --include="*.md" > /dev/null 2>&1; then
    check_pass "Found iOS build command"
else
    check_warn "Missing iOS build command" "Build verifier should reference 'flutter build ios'"
fi

echo ""

# 6. Check for deprecated patterns (things that should NOT be in docs)
echo "🚫 Checking for Deprecated/Incorrect Patterns..."

# Check for incorrect async patterns (missing await)
if grep -r "CloudX\\..*(" "$AGENT_DIR" --include="*.md" | grep -v "await\|Future" | grep -v "//\|#\|\`\`\`" | head -5; then
    check_warn "Found CloudX calls without await" "All CloudX async methods should use 'await'"
fi

# Check for old callback patterns (if any were deprecated)
# (Add specific checks as Flutter SDK evolves)

echo ""

# 7. If Flutter SDK source available, validate against actual API
if [ "$SDK_AVAILABLE" = true ]; then
    echo "🔬 Validating Against Flutter SDK Source..."

    # Check if cloudx.dart exists
    CLOUDX_DART="$FLUTTER_SDK_DIR/lib/cloudx.dart"
    if [ -f "$CLOUDX_DART" ]; then
        check_pass "Found CloudX SDK main file"

        # Check for CloudX class
        if grep -q "class CloudX" "$CLOUDX_DART"; then
            check_pass "CloudX class exists in SDK"
        else
            check_fail "CloudX class not found in SDK" "Check if SDK structure changed"
        fi

        # Check for initialize method
        if grep -q "static.*initialize" "$CLOUDX_DART"; then
            check_pass "initialize() method exists in SDK"
        else
            check_fail "initialize() method not found" "Check if method was renamed"
        fi

        # Check for createBanner method
        if grep -q "createBanner" "$CLOUDX_DART"; then
            check_pass "createBanner() method exists in SDK"
        else
            check_fail "createBanner() method not found" "Check if method was renamed"
        fi

        # Check for createInterstitial method
        if grep -q "createInterstitial" "$CLOUDX_DART"; then
            check_pass "createInterstitial() method exists in SDK"
        else
            check_fail "createInterstitial() method not found" "Check if method was renamed"
        fi

        # Check for destroyAd method
        if grep -q "destroyAd" "$CLOUDX_DART"; then
            check_pass "destroyAd() method exists in SDK"
        else
            check_fail "destroyAd() method not found" "Critical lifecycle method missing!"
        fi

    else
        check_warn "CloudX SDK main file not found" "Expected at $CLOUDX_DART"
    fi

    # Check for CloudXBannerView widget
    BANNER_VIEW="$FLUTTER_SDK_DIR/lib/widgets/cloudx_banner_view.dart"
    if [ -f "$BANNER_VIEW" ] || grep -r "class CloudXBannerView" "$FLUTTER_SDK_DIR/lib" > /dev/null 2>&1; then
        check_pass "CloudXBannerView widget exists in SDK"
    else
        check_warn "CloudXBannerView widget not found" "Check if widget was moved or renamed"
    fi

    echo ""
fi

# 8. Summary
echo "📊 Validation Summary"
echo "===================="
echo ""
echo -e "Total checks:   $TOTAL_CHECKS"
echo -e "${GREEN}Passed:${NC}         $PASSED_CHECKS"
echo -e "${RED}Failed:${NC}         $FAILED_CHECKS"
echo -e "${YELLOW}Warnings:${NC}       $WARNINGS"
echo ""

if [ $FAILED_CHECKS -eq 0 ]; then
    echo -e "${GREEN}✅ All critical checks passed!${NC}"

    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}⚠️  $WARNINGS warning(s) found - review recommended but not critical${NC}"
    fi

    echo ""
    echo "Flutter agents are ready to use!"
    exit 0
else
    echo -e "${RED}❌ $FAILED_CHECKS critical check(s) failed${NC}"
    echo ""
    echo "Please fix the issues above before using agents in production."
    echo ""
    echo "Common fixes:"
    echo "  - Ensure all critical APIs are referenced in agent docs"
    echo "  - Check for typos in API names"
    echo "  - Verify agent files exist and are named correctly"
    echo "  - Update agent docs to match current Flutter SDK version"
    exit 1
fi
