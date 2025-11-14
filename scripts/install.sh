#!/bin/bash

# CloudX SDK - Multi-Platform Agent Installer
# Installs CloudX integration agents for Claude Code (Android + Flutter + iOS)
# Usage: bash install.sh [--global|--local] [--platform=android|flutter|ios|all]

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO_OWNER="cloudx-io"
REPO_NAME="cloudx-sdk-agents"
# Allow branch override via --branch argument or BRANCH env var, default to 'main'
BRANCH="main"
PLATFORM="all"  # Default: install all platforms

# Parse command-line arguments
for arg in "$@"; do
    case $arg in
        --branch=*)
            BRANCH="${arg#*=}"
            shift
            ;;
        --platform=*)
            PLATFORM="${arg#*=}"
            shift
            ;;
    esac
done

# Allow BRANCH environment variable to override (if set)
if [ -n "$BRANCH_ENV" ]; then
    BRANCH="$BRANCH_ENV"
elif [ -n "$BRANCH" ] && [ "$BRANCH" != "main" ]; then
    : # already set by --branch
elif [ -n "$BRANCH" ]; then
    : # already set to default 'main'
fi
BASE_URL="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}"

# Validate platform argument
case $PLATFORM in
    android|flutter|ios|all)
        ;;
    *)
        echo -e "${RED}Error: Invalid platform '${PLATFORM}'${NC}"
        echo "Valid options: android, flutter, ios, all"
        echo "Usage: bash install.sh [--global|--local] [--platform=android|flutter|ios|all]"
        exit 1
        ;;
esac

# Android agent files
ANDROID_AGENTS=(
    "cloudx-android-integrator"
    "cloudx-android-auditor"
    "cloudx-android-build-verifier"
    "cloudx-android-privacy-checker"
)

# Flutter agent files
FLUTTER_AGENTS=(
    "cloudx-flutter-integrator"
    "cloudx-flutter-auditor"
    "cloudx-flutter-build-verifier"
    "cloudx-flutter-privacy-checker"
)

# iOS agent files
IOS_AGENTS=(
    "cloudx-ios-integrator"
    "cloudx-ios-auditor"
    "cloudx-ios-build-verifier"
    "cloudx-ios-privacy-checker"
)

# Helper functions
print_header() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  CloudX SDK Agent Installer (Multi-Platform) ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""
    case $PLATFORM in
        android)
            echo -e "  Platform: ${GREEN}Android${NC}"
            ;;
        flutter)
            echo -e "  Platform: ${GREEN}Flutter${NC}"
            ;;
        ios)
            echo -e "  Platform: ${GREEN}iOS${NC}"
            ;;
        all)
            echo -e "  Platform: ${GREEN}All (Android + Flutter + iOS)${NC}"
            ;;
    esac
    echo ""
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Check if Claude Code is installed (required)
check_claude_code() {
    if command -v claude &> /dev/null; then
        print_success "Claude Code CLI detected"
        return 0
    elif [ -d "$HOME/.claude" ]; then
        print_success "Claude Code directory detected"
        return 0
    else
        print_error "Claude Code is required but not installed"
        echo ""
        echo "   CloudX agents require Claude Code to work."
        echo "   Please install Claude Code first, then run this script again."
        echo ""
        echo "   Install Claude Code:"
        echo -e "   • macOS/Linux: ${BLUE}brew install --cask claude-code${NC}"
        echo -e "   • macOS/Linux: ${BLUE}curl -fsSL https://claude.ai/install.sh | bash${NC}"
        echo "   • Visit: ${BLUE}https://claude.ai/code${NC}"
        echo ""
        exit 1
    fi
}

# Download a single agent file
download_agent() {
    local agent_name=$1
    local target_dir=$2
    local platform_subdir=$3  # "android" or "flutter"
    local url="${BASE_URL}/.claude/agents/${platform_subdir}/${agent_name}.md"
    local target_file="${target_dir}/${agent_name}.md"

    if curl -fsSL "$url" -o "$target_file" 2>/dev/null; then
        print_success "Downloaded ${agent_name}.md"
        return 0
    else
        print_error "Failed to download ${agent_name}.md from ${url}"
        return 1
    fi
}

# Install agents for a specific platform
install_platform_agents() {
    local target_dir=$1
    local platform_name=$2
    shift 2
    local agents=("$@")  # Remaining arguments are agent names

    print_info "Installing ${platform_name} agents..."

    local success_count=0
    for agent in "${agents[@]}"; do
        if download_agent "$agent" "$target_dir" "$platform_name"; then
            ((success_count++))
        fi
    done

    if [ $success_count -eq ${#agents[@]} ]; then
        print_success "Installed all ${success_count} ${platform_name} agents"
        return 0
    else
        print_error "Only installed ${success_count}/${#agents[@]} ${platform_name} agents"
        return 1
    fi
}

# Install agents globally to ~/.claude/agents/
install_global() {
    local agent_dir="$HOME/.claude/agents"

    print_info "Installing agents globally to ${agent_dir}"
    mkdir -p "$agent_dir"
    echo ""

    local total_success=0
    local total_agents=0

    # Install based on platform selection
    case $PLATFORM in
        android)
            install_platform_agents "$agent_dir" "android" "${ANDROID_AGENTS[@]}"
            total_success=$?
            total_agents=${#ANDROID_AGENTS[@]}
            ;;
        flutter)
            install_platform_agents "$agent_dir" "flutter" "${FLUTTER_AGENTS[@]}"
            total_success=$?
            total_agents=${#FLUTTER_AGENTS[@]}
            ;;
        ios)
            install_platform_agents "$agent_dir" "ios" "${IOS_AGENTS[@]}"
            total_success=$?
            total_agents=${#IOS_AGENTS[@]}
            ;;
        all)
            install_platform_agents "$agent_dir" "android" "${ANDROID_AGENTS[@]}"
            local android_success=$?
            echo ""
            install_platform_agents "$agent_dir" "flutter" "${FLUTTER_AGENTS[@]}"
            local flutter_success=$?
            echo ""
            install_platform_agents "$agent_dir" "ios" "${IOS_AGENTS[@]}"
            local ios_success=$?
            total_agents=$((${#ANDROID_AGENTS[@]} + ${#FLUTTER_AGENTS[@]} + ${#IOS_AGENTS[@]}))
            if [ $android_success -eq 0 ] && [ $flutter_success -eq 0 ] && [ $ios_success -eq 0 ]; then
                total_success=0
            else
                total_success=1
            fi
            ;;
    esac

    echo ""
    return $total_success
}

# Install agents locally to current project
install_local() {
    local agent_dir=".claude/agents"

    print_info "Installing agents locally to ${agent_dir}"
    mkdir -p "$agent_dir"
    echo ""

    local total_success=0

    # Install based on platform selection
    case $PLATFORM in
        android)
            install_platform_agents "$agent_dir" "android" "${ANDROID_AGENTS[@]}"
            total_success=$?
            ;;
        flutter)
            install_platform_agents "$agent_dir" "flutter" "${FLUTTER_AGENTS[@]}"
            total_success=$?
            ;;
        ios)
            install_platform_agents "$agent_dir" "ios" "${IOS_AGENTS[@]}"
            total_success=$?
            ;;
        all)
            install_platform_agents "$agent_dir" "android" "${ANDROID_AGENTS[@]}"
            local android_success=$?
            echo ""
            install_platform_agents "$agent_dir" "flutter" "${FLUTTER_AGENTS[@]}"
            local flutter_success=$?
            echo ""
            install_platform_agents "$agent_dir" "ios" "${IOS_AGENTS[@]}"
            local ios_success=$?
            if [ $android_success -eq 0 ] && [ $flutter_success -eq 0 ] && [ $ios_success -eq 0 ]; then
                total_success=0
            else
                total_success=1
            fi
            ;;
    esac

    echo ""
    return $total_success
}

# Verify installation
verify_installation() {
    local agent_dir=$1

    echo ""
    print_info "Verifying installation..."

    local found_count=0
    local total_expected=0

    case $PLATFORM in
        android)
            total_expected=${#ANDROID_AGENTS[@]}
            for agent in "${ANDROID_AGENTS[@]}"; do
                if [ -f "${agent_dir}/${agent}.md" ]; then
                    ((found_count++))
                fi
            done
            ;;
        flutter)
            total_expected=${#FLUTTER_AGENTS[@]}
            for agent in "${FLUTTER_AGENTS[@]}"; do
                if [ -f "${agent_dir}/${agent}.md" ]; then
                    ((found_count++))
                fi
            done
            ;;
        ios)
            total_expected=${#IOS_AGENTS[@]}
            for agent in "${IOS_AGENTS[@]}"; do
                if [ -f "${agent_dir}/${agent}.md" ]; then
                    ((found_count++))
                fi
            done
            ;;
        all)
            total_expected=$((${#ANDROID_AGENTS[@]} + ${#FLUTTER_AGENTS[@]} + ${#IOS_AGENTS[@]}))
            for agent in "${ANDROID_AGENTS[@]}" "${FLUTTER_AGENTS[@]}" "${IOS_AGENTS[@]}"; do
                if [ -f "${agent_dir}/${agent}.md" ]; then
                    ((found_count++))
                fi
            done
            ;;
    esac

    if [ $found_count -eq $total_expected ]; then
        print_success "All agents verified"
        return 0
    else
        print_warning "Found ${found_count}/${total_expected} agents"
        return 1
    fi
}

# Show usage instructions
show_usage() {
    echo "Usage: bash install.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --local               Install agents to current project's .claude/agents/ (default)"
    echo "  --global              Install agents globally to ~/.claude/agents/"
    echo "  --platform=PLATFORM   Choose platform: android, flutter, ios, or all (default: all)"
    echo "  --branch=BRANCH       Install from specific branch (default: main)"
    echo "  --help                Show this help message"
    echo ""
    echo "Examples:"
    echo "  bash install.sh                           # Install all platforms locally"
    echo "  bash install.sh --local                   # Install all platforms to current project"
    echo "  bash install.sh --global                  # Install all platforms globally"
    echo "  bash install.sh --platform=android        # Install only Android agents locally"
    echo "  bash install.sh --platform=flutter        # Install only Flutter agents locally"
    echo "  bash install.sh --platform=ios            # Install only iOS agents locally"
    echo "  bash install.sh --global --platform=ios   # Install iOS agents globally"
}

# Show next steps
show_next_steps() {
    local install_type=$1

    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║         Installation Complete!         ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo "📦 Installed Agents:"

    case $PLATFORM in
        android)
            for agent in "${ANDROID_AGENTS[@]}"; do
                echo "   • ${agent}"
            done
            ;;
        flutter)
            for agent in "${FLUTTER_AGENTS[@]}"; do
                echo "   • ${agent}"
            done
            ;;
        ios)
            for agent in "${IOS_AGENTS[@]}"; do
                echo "   • ${agent}"
            done
            ;;
        all)
            echo "   Android:"
            for agent in "${ANDROID_AGENTS[@]}"; do
                echo "     • ${agent}"
            done
            echo "   Flutter:"
            for agent in "${FLUTTER_AGENTS[@]}"; do
                echo "     • ${agent}"
            done
            echo "   iOS:"
            for agent in "${IOS_AGENTS[@]}"; do
                echo "     • ${agent}"
            done
            ;;
    esac

    echo ""
    echo "🚀 Next Steps:"
    echo ""

    if [ "$install_type" = "local" ]; then
        echo "1. Launch Claude Code in this project:"
        echo -e "   ${BLUE}claude${NC}"
        echo ""
    else
        case $PLATFORM in
            android)
                echo "1. Navigate to your Android project:"
                echo -e "   ${BLUE}cd /path/to/your/android/project${NC}"
                ;;
            flutter)
                echo "1. Navigate to your Flutter project:"
                echo -e "   ${BLUE}cd /path/to/your/flutter/project${NC}"
                ;;
            ios)
                echo "1. Navigate to your iOS project:"
                echo -e "   ${BLUE}cd /path/to/your/ios/project${NC}"
                ;;
            all)
                echo "1. Navigate to your project:"
                echo -e "   ${BLUE}cd /path/to/your/project${NC}"
                ;;
        esac
        echo ""
        echo "2. Launch Claude Code:"
        echo -e "   ${BLUE}claude${NC}"
        echo ""
    fi

    echo "3. Ask Claude to integrate CloudX SDK:"
    case $PLATFORM in
        android)
            echo -e "   ${YELLOW}Use @agent-cloudx-android-integrator to integrate CloudX SDK with app key: YOUR_KEY${NC}"
            ;;
        flutter)
            echo -e "   ${YELLOW}Use @agent-cloudx-flutter-integrator to integrate CloudX SDK with app key: YOUR_KEY${NC}"
            ;;
        ios)
            echo -e "   ${YELLOW}Use @agent-cloudx-ios-integrator to integrate CloudX SDK with app key: YOUR_KEY${NC}"
            ;;
        all)
            echo -e "   Android: ${YELLOW}Use @agent-cloudx-android-integrator to integrate CloudX SDK${NC}"
            echo -e "   Flutter: ${YELLOW}Use @agent-cloudx-flutter-integrator to integrate CloudX SDK${NC}"
            echo -e "   iOS: ${YELLOW}Use @agent-cloudx-ios-integrator to integrate CloudX SDK${NC}"
            ;;
    esac

    echo ""
    echo "4. The agents will automatically:"
    echo "   ✓ Add CloudX dependencies"
    echo "   ✓ Implement initialization"
    echo "   ✓ Create fallback logic (if AdMob/AppLovin exists)"
    echo "   ✓ Validate privacy compliance"
    echo "   ✓ Run build verification"
    echo ""
    echo "📚 Documentation:"
    case $PLATFORM in
        android)
            echo "   • Setup Guide: https://github.com/${REPO_OWNER}/${REPO_NAME}/blob/${BRANCH}/docs/android/SETUP.md"
            echo "   • Integration Guide: https://github.com/${REPO_OWNER}/${REPO_NAME}/blob/${BRANCH}/docs/android/INTEGRATION_GUIDE.md"
            ;;
        flutter)
            echo "   • Setup Guide: https://github.com/${REPO_OWNER}/${REPO_NAME}/blob/${BRANCH}/docs/flutter/SETUP.md"
            echo "   • Integration Guide: https://github.com/${REPO_OWNER}/${REPO_NAME}/blob/${BRANCH}/docs/flutter/INTEGRATION_GUIDE.md"
            ;;
        ios)
            echo "   • Setup Guide: https://github.com/${REPO_OWNER}/${REPO_NAME}/blob/${BRANCH}/docs/ios/SETUP.md"
            echo "   • Integration Guide: https://github.com/${REPO_OWNER}/${REPO_NAME}/blob/${BRANCH}/docs/ios/INTEGRATION_GUIDE.md"
            ;;
        all)
            echo "   • Android: https://github.com/${REPO_OWNER}/${REPO_NAME}/blob/${BRANCH}/docs/android/"
            echo "   • Flutter: https://github.com/${REPO_OWNER}/${REPO_NAME}/blob/${BRANCH}/docs/flutter/"
            echo "   • iOS: https://github.com/${REPO_OWNER}/${REPO_NAME}/blob/${BRANCH}/docs/ios/"
            ;;
    esac
    echo "   • Agent Reference: https://github.com/${REPO_OWNER}/${REPO_NAME}/blob/${BRANCH}/README.md"
    echo ""
    echo "💬 Need Help?"
    echo "   • GitHub Issues: https://github.com/${REPO_OWNER}/${REPO_NAME}/issues"
    echo "   • Email: mobile@cloudx.io"
    echo ""
}

# Main installation flow
main() {
    print_header

    # Parse arguments
    local install_type="local"

    case "${1:-}" in
        --help|-h)
            show_usage
            exit 0
            ;;
        --global|-g)
            install_type="global"
            ;;
        --local|-l|"")
            install_type="local"
            ;;
        *)
            print_error "Unknown option: $1"
            echo ""
            show_usage
            exit 1
            ;;
    esac

    # Check prerequisites
    print_info "Checking prerequisites..."

    # Check for curl
    if ! command -v curl &> /dev/null; then
        print_error "curl is required but not installed"
        exit 1
    fi
    print_success "curl detected"

    # Check for Claude Code (optional)
    check_claude_code

    echo ""

    # Install agents
    if [ "$install_type" = "local" ]; then
        if install_local; then
            verify_installation ".claude/agents"
            show_next_steps "local"
            exit 0
        else
            exit 1
        fi
    else
        if install_global; then
            verify_installation "$HOME/.claude/agents"
            show_next_steps "global"
            exit 0
        else
            exit 1
        fi
    fi
}

# Run main function
main "$@"
