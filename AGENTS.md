# AGENTS.md

This repository packages AI-agent guidance for integrating the **CloudX SDK**
into publisher apps (Android, iOS, React Native, Flutter, Unity). It works with
any agent that can read files and fetch URLs — Claude Code, Codex, Cursor, and
others.

## The one rule

**This repository contains no product facts, and neither does your memory.**
SDK versions, dependency coordinates, APIs, ad-format guidance, and adapter
matrices live on the docs site and are fetched at run time:

- Page index: `https://docs.cloudx.io/llms.txt`
- Every listed page is raw markdown at its `.md` URL
  (e.g. `https://docs.cloudx.io/en/android/integration.md`)
- Alternative: the CloudX MCP server's `SearchDocs` tool, if configured
  (`https://docs.cloudx.io/en/mcp/installation.md`)

Never write a CloudX version number, coordinate, or API signature from memory.
Fetch first, always.

## Repository map

- `.agents/skills/cloudx-integrate/` — the integration workflow skill:
  Detect → Plan → Integrate → Build-verify → Audit → Report. Start here for
  any "integrate CloudX" task. Its `references/doc-map.md` maps questions to
  docs pages; `references/playbook-index.md` maps project signals to playbooks.
- `.agents/skills/cloudx-audit/` — standalone audit of an existing CloudX
  integration.
- `playbooks/` — field knowledge the docs site does not cover: coexisting with
  an existing mediation stack (AppLovin MAX, LevelPlay, Google, or another —
  first-look or parallel), migrating off a mediation stack, CMP/consent
  handling, and per-platform build-system quirks. Load only the playbooks
  whose signals match the project.

## For agent tooling maintainers

- `.agents/skills/` is the canonical skill catalog. `.claude/skills` is a
  compatibility symlink; `.claude-plugin/` packages the same skills as a
  Claude Code plugin. Do not create copies.
- Playbooks must contain only knowledge absent from docs.cloudx.io, link docs
  pages instead of restating them, and contain no version numbers. CI enforces
  the no-hardcoded-version rule and checks every docs link against the live
  site (`scripts/verify.sh`).
