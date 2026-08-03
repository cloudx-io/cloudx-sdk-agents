# CloudX SDK Agents

AI-agent guidance for integrating the [CloudX SDK](https://docs.cloudx.io) into
publisher apps — Android, iOS, React Native, Flutter, and Unity. Works with
Claude Code, Codex, Cursor, and any agent that can read files and fetch URLs.

**How it stays accurate:** this repository contains no SDK versions, no API
references, and no dependency coordinates. Agents fetch all facts live from
[docs.cloudx.io](https://docs.cloudx.io) (machine-readable index at
[`/llms.txt`](https://docs.cloudx.io/llms.txt)), which is updated with every
SDK release. What lives here is the part docs can't hold: the integration
**workflow** and **playbooks** for real-world situations — coexisting with
AppLovin MAX or LevelPlay, CMP/consent handling, build-system quirks, and
mediation migrations. CI fails any commit that hardcodes a version.

## Install

### Claude Code (recommended)

```
/plugin marketplace add cloudx-io/cloudx-sdk-agents
/plugin install cloudx@cloudx
```

Then, in your app project:

> integrate CloudX with app key YOUR_APP_KEY

### Cursor / Codex / other agents

Clone this repo (or vendor `AGENTS.md`, `.agents/skills/`, and `playbooks/`
into your app repo). `AGENTS.md` is the entry point; both tools pick it up
natively. Vendored copies stay safe when old — they contain no facts, only the
instruction to fetch facts live.

### No install

Paste into any agent with web access:

> Follow https://raw.githubusercontent.com/cloudx-io/cloudx-sdk-agents/main/.agents/skills/cloudx-integrate/SKILL.md
> to integrate the CloudX SDK into this project.

## What's included

| Piece | Purpose |
|---|---|
| `cloudx-integrate` skill | Phased integration workflow: Detect → Plan → Integrate → Build-verify → Audit → Report |
| `cloudx-audit` skill | Check an existing CloudX integration against the current docs |
| `playbooks/` | Field knowledge: MAX/LevelPlay/Google coexistence, mediation migration, consent & CMPs, Android/iOS/Unity/RN/Flutter build quirks |

Platform status: docs-driven integration works for all five platforms.
Playbooks are seeded from real cases for Android and iOS scenarios; wrapper
platform playbooks (Unity, React Native, Flutter) start as stubs and grow as
support cases surface.

## Migrating from v1

The previous generation of this repo shipped four Android subagents
(`@agent-cloudx-android-integrator`, `-auditor`, `-build-verifier`,
`-privacy-checker`) installed by a curl script into `.claude/agents/`. Those
files embed an API snapshot that is now two major SDK versions old and
generates code that no longer compiles. If you installed them:

```bash
bash scripts/uninstall-legacy.sh
```

then install the plugin as above. Old invocations map to plain phrases:
"integrate CloudX" (integrator / build-verifier / privacy-checker) and
"audit my CloudX integration" (auditor). The v1 tree is preserved at the
`v1-legacy` tag.

## Contributing playbooks

Playbooks hold only knowledge absent from [docs.cloudx.io](https://docs.cloudx.io):
link docs pages instead of restating them, and never include version numbers
(CI enforces this). Each playbook declares `applies_to`, detection `signals`,
and `last_verified` frontmatter. Run `scripts/verify.sh` locally before opening
a PR.

## Resources

- Documentation: https://docs.cloudx.io
- CloudX MCP server (reporting + docs search in your agent): https://docs.cloudx.io/en/mcp/installation.md
- Dashboard: https://app.cloudx.io
- Issues: https://github.com/cloudx-io/cloudx-sdk-agents/issues
