#!/bin/bash

# CloudX iOS Agent API Validation Script
# Validates that iOS agent documentation references match actual SDK APIs
# This script is meant to be run from the cloudx-sdk-agents repository

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SDK_VERSION_FILE="$REPO_ROOT/SDK_VERSION.yaml"

# iOS SDK repository path (can be overridden via environment variable)
IOS_SDK_DIR="${IOS_SDK_DIR:-$REPO_ROOT/../cloudx-ios-private}"

# Agent files to validate
AGENT_DIR="$REPO_ROOT/.claude/agents/ios"
INTEGRATOR="$AGENT_DIR/cloudx-ios-integrator.md"
AUDITOR="$AGENT_DIR/cloudx-ios-auditor.md"
BUILD_VERIFIER="$AGENT_DIR/cloudx-ios-build-verifier.md"
PRIVACY_CHECKER="$AGENT_DIR/cloudx-ios-privacy-checker.md"

# Counters
PASS_COUNT=0
FAIL_COUNT=0
SKIP_COUNT=0

# Helper functions
print_header() {
    echo ""
    echo -e "${BLUE}╔═══════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  CloudX iOS Agent API Validation                 ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_section() {
    echo ""
    echo -e "${BLUE}▶ $1${NC}"
    echo ""
}

check_pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASS_COUNT++))
}

check_fail() {
    echo -e "${RED}✗${NC} $1"
    ((FAIL_COUNT++))
}

check_skip() {
    echo -e "${YELLOW}⊘${NC} $1"
    ((SKIP_COUNT++))
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    print_section "Checking Prerequisites"

    # Check if SDK directory exists
    if [ ! -d "$IOS_SDK_DIR" ]; then
        check_fail "iOS SDK directory not found at: $IOS_SDK_DIR"
        echo ""
        echo "   Set IOS_SDK_DIR environment variable to SDK path:"
        echo -e "   ${BLUE}export IOS_SDK_DIR=/path/to/cloudx-ios-private${NC}"
        echo ""
        exit 1
    fi
    check_pass "iOS SDK directory found: $IOS_SDK_DIR"

    # Check if main API header exists
    if [ ! -f "$IOS_SDK_DIR/core/Sources/CloudXCore/CloudXCoreAPI.h" ]; then
        check_fail "CloudXCoreAPI.h not found in SDK"
        exit 1
    fi
    check_pass "CloudXCoreAPI.h found"

    # Check if agent files exist
    if [ ! -f "$INTEGRATOR" ]; then
        check_fail "Integrator agent not found: $INTEGRATOR"
        exit 1
    fi
    check_pass "All agent files found"

    # Check for yq or grep for YAML parsing (optional)
    if command -v yq &> /dev/null; then
        check_pass "yq found (enhanced YAML parsing available)"
    else
        check_skip "yq not found (using grep for YAML parsing)"
    fi
}

# Get iOS SDK version from SDK
get_sdk_version() {
    local version_file="$IOS_SDK_DIR/core/Sources/CloudXCore/CLXVersion.m"
    if [ -f "$version_file" ]; then
        # Extract version like: NSString * const CLXSDKVersion = @"1.2.0";
        grep -o 'CLXSDKVersion = @"[^"]*"' "$version_file" | cut -d'"' -f2
    else
        echo "unknown"
    fi
}

# Get iOS SDK version from agent documentation
get_documented_version() {
    if command -v yq &> /dev/null; then
        yq eval '.platforms.ios.sdk_version' "$SDK_VERSION_FILE" 2>/dev/null || echo "unknown"
    else
        grep -A 1 "^  ios:" "$SDK_VERSION_FILE" | grep "sdk_version:" | awk '{print $2}' | tr -d '"'
    fi
}

# Validate SDK version matches
validate_sdk_version() {
    print_section "Validating SDK Version"

    local sdk_version=$(get_sdk_version)
    local doc_version=$(get_documented_version)

    print_info "SDK version (CLXVersion.m): $sdk_version"
    print_info "Documented version (SDK_VERSION.yaml): $doc_version"

    if [ "$sdk_version" = "$doc_version" ]; then
        check_pass "SDK version matches documented version ($sdk_version)"
    else
        check_fail "SDK version mismatch: SDK=$sdk_version, Docs=$doc_version"
    fi
}

# Validate iOS-specific API classes exist
validate_core_classes() {
    print_section "Validating Core Classes"

    local api_header="$IOS_SDK_DIR/core/Sources/CloudXCore/CloudXCoreAPI.h"

    # Check for CloudXCore class
    if grep -q "@interface CloudXCore" "$api_header"; then
        check_pass "CloudXCore class exists in SDK"
    else
        check_fail "CloudXCore class not found in SDK"
    fi

    # Check for ad view classes
    local classes=("CLXBannerAdView" "CLXMRECAdView" "CLXInterstitial" "CLXRewardedAd" "CLXNativeAd")
    for class in "${classes[@]}"; do
        if grep -rq "@interface $class" "$IOS_SDK_DIR/core/Sources/CloudXCore/"; then
            check_pass "$class class exists"
        else
            check_fail "$class class not found"
        fi
    done
}

# Validate delegate protocols exist
validate_delegates() {
    print_section "Validating Delegate Protocols"

    local delegates=("CLXBannerDelegate" "CLXMRECDelegate" "CLXInterstitialDelegate" "CLXRewardedDelegate" "CLXNativeDelegate")

    for delegate in "${delegates[@]}"; do
        if grep -rq "@protocol $delegate" "$IOS_SDK_DIR/core/Sources/CloudXCore/"; then
            check_pass "$delegate protocol exists"
        else
            check_fail "$delegate protocol not found"
        fi
    done
}

# Validate factory methods exist in CloudXCore
validate_factory_methods() {
    print_section "Validating Factory Methods"

    local api_header="$IOS_SDK_DIR/core/Sources/CloudXCore/CloudXCoreAPI.h"

    # Check for createBanner
    if grep -q "createBannerWithPlacement:" "$api_header"; then
        check_pass "createBannerWithPlacement: method exists"
    else
        check_fail "createBannerWithPlacement: method not found"
    fi

    # Check for createInterstitial
    if grep -q "createInterstitialWithPlacement:" "$api_header"; then
        check_pass "createInterstitialWithPlacement: method exists"
    else
        check_fail "createInterstitialWithPlacement: method not found"
    fi

    # Check for createRewarded
    if grep -q "createRewardedWithPlacement:" "$api_header"; then
        check_pass "createRewardedWithPlacement: method exists"
    else
        check_fail "createRewardedWithPlacement: method not found"
    fi

    # Check for createMREC
    if grep -q "createMRECWithPlacement:" "$api_header"; then
        check_pass "createMRECWithPlacement: method exists"
    else
        check_fail "createMRECWithPlacement: method not found"
    fi

    # Check for createNative
    if grep -q "createNativeWithPlacement:" "$api_header"; then
        check_pass "createNativeWithPlacement: method exists"
    else
        check_fail "createNativeWithPlacement: method not found"
    fi
}

# Validate initialization API
validate_initialization() {
    print_section "Validating Initialization API"

    local api_header="$IOS_SDK_DIR/core/Sources/CloudXCore/CloudXCoreAPI.h"

    # Check for initializeSDKWithAppKey
    if grep -q "initializeSDKWithAppKey:" "$api_header"; then
        check_pass "initializeSDKWithAppKey:completion: method exists"
    else
        check_fail "initializeSDKWithAppKey: method not found"
    fi

    # Check for shared singleton
    if grep -q "\+ (instancetype)shared" "$api_header" || grep -q "sharedInstance" "$api_header"; then
        check_pass "CloudXCore singleton pattern exists"
    else
        check_fail "CloudXCore singleton not found"
    fi
}

# Validate privacy APIs
validate_privacy_apis() {
    print_section "Validating Privacy APIs"

    local api_header="$IOS_SDK_DIR/core/Sources/CloudXCore/CloudXCoreAPI.h"

    # Check for CCPA
    if grep -q "setCCPAPrivacyString:" "$api_header"; then
        check_pass "setCCPAPrivacyString: method exists"
    else
        check_fail "setCCPAPrivacyString: method not found"
    fi

    # Check for GDPR
    if grep -q "setIsUserConsent:" "$api_header"; then
        check_pass "setIsUserConsent: method exists"
    else
        check_fail "setIsUserConsent: method not found"
    fi

    # Check for COPPA
    if grep -q "setIsAgeRestrictedUser:" "$api_header"; then
        check_pass "setIsAgeRestrictedUser: method exists"
    else
        check_fail "setIsAgeRestrictedUser: method not found"
    fi
}

# Validate delegate callback signatures
validate_delegate_callbacks() {
    print_section "Validating Delegate Callback Signatures"

    # Check for banner callbacks
    if grep -rq "bannerDidLoad:" "$IOS_SDK_DIR/core/Sources/CloudXCore/"; then
        check_pass "bannerDidLoad: callback exists"
    else
        check_fail "bannerDidLoad: callback not found"
    fi

    if grep -rq "bannerDidFailToLoad:.*withError:" "$IOS_SDK_DIR/core/Sources/CloudXCore/"; then
        check_pass "bannerDidFailToLoad:withError: callback exists"
    else
        check_fail "bannerDidFailToLoad:withError: callback not found"
    fi

    # Check for interstitial callbacks
    if grep -rq "interstitialDidLoad:" "$IOS_SDK_DIR/core/Sources/CloudXCore/"; then
        check_pass "interstitialDidLoad: callback exists"
    else
        check_fail "interstitialDidLoad: callback not found"
    fi

    if grep -rq "interstitialDidFailToLoad:.*withError:" "$IOS_SDK_DIR/core/Sources/CloudXCore/"; then
        check_pass "interstitialDidFailToLoad:withError: callback exists"
    else
        check_fail "interstitialDidFailToLoad:withError: callback not found"
    fi

    # Check for rewarded callbacks
    if grep -rq "rewardedUserDidEarnReward:" "$IOS_SDK_DIR/core/Sources/CloudXCore/"; then
        check_pass "rewardedUserDidEarnReward: callback exists"
    else
        check_fail "rewardedUserDidEarnReward: callback not found"
    fi
}

# Validate agent documentation doesn't use deprecated patterns
validate_no_deprecated_apis() {
    print_section "Checking for Deprecated API Usage in Agents"

    local deprecated_found=false

    # Check for old initialization patterns (if any were deprecated)
    # Example: if initWithAppKey was replaced by initializeSDKWithAppKey
    if grep -q "initWithAppKey:" "$INTEGRATOR" 2>/dev/null; then
        check_fail "Deprecated initWithAppKey: found in integrator (should use initializeSDKWithAppKey:)"
        deprecated_found=true
    fi

    if ! $deprecated_found; then
        check_pass "No deprecated API patterns found in agent documentation"
    fi
}

# Validate show methods for fullscreen ads
validate_show_methods() {
    print_section "Validating Show Methods"

    # Check for showFromViewController in interstitial
    if grep -rq "showFromViewController:" "$IOS_SDK_DIR/core/Sources/CloudXCore/"; then
        check_pass "showFromViewController: method exists for fullscreen ads"
    else
        check_fail "showFromViewController: method not found"
    fi

    # Verify agent docs use correct show method
    if grep -q "show(from:" "$INTEGRATOR" || grep -q "showFromViewController:" "$INTEGRATOR"; then
        check_pass "Agent documentation uses correct show method"
    else
        check_fail "Agent documentation missing show(from:)/showFromViewController: pattern"
    fi
}

# Validate UIViewController requirements are documented
validate_view_controller_requirements() {
    print_section "Validating UIViewController Requirements"

    # Check that agents document UIViewController requirement for banner/MREC/native
    if grep -iq "UIViewController" "$INTEGRATOR"; then
        check_pass "Agent documentation mentions UIViewController requirement"
    else
        check_fail "Agent documentation missing UIViewController requirement"
    fi

    # Check that banner creation requires viewController parameter
    if grep -q "viewController:" "$IOS_SDK_DIR/core/Sources/CloudXCore/CloudXCoreAPI.h"; then
        check_pass "Banner creation API includes viewController parameter"
    else
        check_fail "Banner creation missing viewController parameter"
    fi
}

# Print summary report
print_summary() {
    echo ""
    echo -e "${BLUE}╔═══════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  Validation Summary                               ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}Passed:${NC}  $PASS_COUNT"
    echo -e "${RED}Failed:${NC}  $FAIL_COUNT"
    echo -e "${YELLOW}Skipped:${NC} $SKIP_COUNT"
    echo ""

    if [ $FAIL_COUNT -eq 0 ]; then
        echo -e "${GREEN}✓ All validations passed!${NC}"
        echo ""
        return 0
    else
        echo -e "${RED}✗ $FAIL_COUNT validation(s) failed${NC}"
        echo ""
        echo "Action Items:"
        echo "  1. Review failed checks above"
        echo "  2. Update agent documentation to match current SDK APIs"
        echo "  3. Update SDK_VERSION.yaml if SDK version changed"
        echo "  4. Re-run this validation script"
        echo ""
        return 1
    fi
}

# Main execution
main() {
    print_header

    check_prerequisites
    validate_sdk_version
    validate_core_classes
    validate_delegates
    validate_factory_methods
    validate_initialization
    validate_privacy_apis
    validate_delegate_callbacks
    validate_show_methods
    validate_view_controller_requirements
    validate_no_deprecated_apis

    print_summary
}

# Run main function
main
exit_code=$?
exit $exit_code
