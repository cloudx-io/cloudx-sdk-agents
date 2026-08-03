#!/usr/bin/env bash
# DEPRECATED. This installer belonged to the v1 curl-installed agents, which
# embed an outdated CloudX SDK API snapshot and generate code that no longer
# compiles. It intentionally installs nothing.
set -euo pipefail

cat <<'EOF'
==============================================================================
  This installer is deprecated and no longer installs anything.

  The CloudX SDK agents are now distributed as a Claude Code plugin backed by
  live documentation (nothing to go stale). Install with:

      /plugin marketplace add cloudx-io/cloudx-sdk-agents
      /plugin install cloudx@cloudx

  Using Cursor or Codex? Clone the repo instead — AGENTS.md is the entry
  point:  https://github.com/cloudx-io/cloudx-sdk-agents

  If you previously installed the old agents, remove them with:

      bash scripts/uninstall-legacy.sh

==============================================================================
EOF
exit 1
