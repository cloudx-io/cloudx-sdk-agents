#!/bin/bash
# Checks that all public SDK APIs are documented in agent files
# This is a coverage check - ensures agents mention all available features

# Note: We do NOT use 'set -e' because grep returns exit code 1 when no match found
# This is expected behavior, not an error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
AGENT_DIR="$REPO_ROOT/.claude/agents"

# SDK_DIR can be provided via env var or default to sibling repo
SDK_DIR="${SDK_DIR:-$(dirname "$REPO_ROOT")/cloudexchange.android.sdk/sdk/src/main/java/io/cloudx/sdk}"

echo "🔍 CloudX API Coverage Check"
echo "================================"
echo ""

# Check if SDK source is available
if [ ! -d "$SDK_DIR" ]; then
    echo "⚠️  SDK source not found at: $SDK_DIR"
    echo ""
    echo "This script requires SDK source code to check API coverage."
    echo "Set SDK_DIR environment variable to point to SDK source:"
    echo "export SDK_DIR=/path/to/cloudexchange.android.sdk/sdk/src/main/java/io/cloudx/sdk"
    echo ""
    echo "Skipping coverage check."
    exit 0
fi

echo "✅ SDK source found: $SDK_DIR"
echo ""

# Track results
TOTAL_APIS=0
DOCUMENTED_APIS=0
MISSING_APIS=0

# Extract public APIs from SDK
# Looking for: public classes, interfaces, objects, and top-level functions
echo "📊 Analyzing SDK Public APIs..."
echo ""

# Find public classes and interfaces
PUBLIC_TYPES=$(find "$SDK_DIR" -name "*.kt" -type f -exec grep -h "^class \|^interface \|^object \|^data class " {} \; \
    | grep -v "internal\|private" \
    | awk '{print $2}' \
    | cut -d'(' -f1 \
    | cut -d':' -f1 \
    | sort -u)

# Find public functions in CloudX.kt (main entry point)
PUBLIC_FUNCTIONS=$(grep -h "^    @JvmStatic\|^    fun " "$SDK_DIR/CloudX.kt" 2>/dev/null \
    | grep -v "internal\|private" \
    | grep "fun " \
    | awk '{print $2}' \
    | cut -d'(' -f1 \
    | sort -u)

# Combine all APIs
ALL_APIS=$(echo -e "$PUBLIC_TYPES\n$PUBLIC_FUNCTIONS" | grep -v "^$" | sort -u)

echo "📋 Checking API Coverage..."
echo ""

# Check each API
while IFS= read -r api; do
    ((TOTAL_APIS++))

    # Skip common Kotlin names that aren't part of our API
    if [[ "$api" =~ ^(Companion|Builder|hashCode|equals|toString|copy)$ ]]; then
        continue
    fi

    # Check if API is mentioned in any agent file
    if grep -rq "\b$api\b" "$AGENT_DIR/" 2>/dev/null; then
        echo -e "${GREEN}✅${NC} $api - documented"
        ((DOCUMENTED_APIS++))
    else
        echo -e "${YELLOW}⚠️${NC}  $api - NOT documented in agents"
        ((MISSING_APIS++))
    fi
done <<< "$ALL_APIS"

echo ""
echo "================================"
echo "📊 Coverage Summary"
echo "================================"
echo -e "Total Public APIs:     $TOTAL_APIS"
echo -e "${GREEN}Documented:            $DOCUMENTED_APIS${NC}"
echo -e "${YELLOW}Missing from agents:   $MISSING_APIS${NC}"

if [ $TOTAL_APIS -gt 0 ]; then
    COVERAGE=$((DOCUMENTED_APIS * 100 / TOTAL_APIS))
    echo -e "Coverage:              ${COVERAGE}%"
fi

echo ""

if [ $MISSING_APIS -gt 0 ]; then
    echo -e "${YELLOW}⚠️  INCOMPLETE COVERAGE${NC}"
    echo ""
    echo "Some public SDK APIs are not documented in agents."
    echo "This means publishers won't know about these features."
    echo ""
    echo "Action:"
    echo "1. Review undocumented APIs above"
    echo "2. If they're important, add to agent documentation"
    echo "3. If they're internal/deprecated, mark them as internal in SDK"
    echo ""
    exit 0  # Warning, not failure
else
    echo -e "${GREEN}✅ COMPLETE COVERAGE${NC}"
    echo ""
    echo "All public SDK APIs are mentioned in agent documentation."
    echo ""
    exit 0
fi
