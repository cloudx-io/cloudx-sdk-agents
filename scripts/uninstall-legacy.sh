#!/usr/bin/env bash
# Remove v1 CloudX agent files (the pre-plugin generation of this repo).
# v1 installed four Android subagents via curl into ~/.claude/agents/ (global)
# or <project>/.claude/agents/ (local). Their content embeds an outdated API
# snapshot and should not be used.
set -euo pipefail

AGENTS=(
  cloudx-android-integrator.md
  cloudx-android-auditor.md
  cloudx-android-build-verifier.md
  cloudx-android-privacy-checker.md
)

remove_from() {
  local base="$1" removed=0
  for name in "${AGENTS[@]}"; do
    for f in "$base/$name" "$base/android/$name"; do
      if [ -f "$f" ]; then
        rm "$f"
        echo "removed $f"
        removed=1
      fi
    done
  done
  # Clean up the empty android/ subdirectory v1 created.
  [ -d "$base/android" ] && rmdir "$base/android" 2>/dev/null || true
  return $removed
}

FOUND=0
remove_from "$HOME/.claude/agents" || FOUND=1
remove_from ".claude/agents" || FOUND=1

if [ "$FOUND" -eq 0 ]; then
  echo "No v1 CloudX agent files found in ~/.claude/agents or ./.claude/agents."
else
  echo
  echo "v1 agents removed. Install the current plugin in Claude Code with:"
  echo "  /plugin marketplace add cloudx-io/cloudx-sdk-agents"
  echo "  /plugin install cloudx@cloudx"
fi
