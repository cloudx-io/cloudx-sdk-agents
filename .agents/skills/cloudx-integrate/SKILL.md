---
name: cloudx-integrate
description: Integrate the CloudX SDK into a publisher app on any supported platform (Android, iOS, React Native, Flutter, Unity). Use when asked to integrate, add, install, or set up CloudX, CloudX ads, or CloudX mediation in an app, including alongside or replacing an existing mediation stack such as AppLovin MAX, LevelPlay, or AdMob.
---

# CloudX SDK Integration

You are integrating the CloudX SDK into the publisher's app. This skill supplies
the workflow and field knowledge. **All product facts come from the docs site at
run time — never from this skill and never from memory.**

## Iron rules

1. **Never state an SDK version, dependency coordinate, API signature, class or
   method name, adapter list, or supported-format claim from memory.** Fetch the
   relevant docs page first, every session. Your training data is stale for this
   SDK by definition.
2. The docs site is the sole source of API truth: fetch
   `https://docs.cloudx.io/llms.txt` for the page index; every page listed there
   is retrievable as raw markdown at its `.md` URL. If the CloudX MCP server is
   configured, its `SearchDocs` tool is an equivalent alternative.
3. Current versions and dependency coordinates come from the platform's
   integration overview page (e.g. `en/android/integration.md`) — not from
   package registries and not from this repository.
4. This repository's `playbooks/` hold real-world scenario knowledge that the
   docs do not cover. Load only the playbooks whose detection signals match the
   project (see `references/playbook-index.md`).

## Workflow

Work through the phases in order. Do not skip Detect — it drives everything else.

### Phase 1 — Detect

Identify, from the project's files:

- **Platform**: `build.gradle`/`build.gradle.kts` → Android; `*.xcodeproj`,
  `Podfile`, or `Package.swift` → iOS; `pubspec.yaml` → Flutter; React Native
  in `package.json` → React Native; `ProjectSettings/` → Unity. A Flutter,
  React Native, or Unity project also contains native subprojects — the wrapper
  platform wins.
- **Existing ad/mediation SDKs** and **CMP/consent tooling** — match the
  signals in `references/playbook-index.md` and note every playbook that applies.
- **Build system specifics** (Gradle DSL and dependency style, CocoaPods vs SPM,
  minification) — also playbook-index signals.
- Whether the user supplied an **app key** and **ad unit IDs**. If not, proceed
  with clearly marked placeholders and list them in the final report.

### Phase 2 — Plan

1. Fetch `https://docs.cloudx.io/llms.txt`.
2. Establish the adapter set. The correct list is **the networks enabled for
   this app in the publisher's CloudX dashboard configuration** — adapters are
   activated by the server-provisioned config at runtime, so an adapter for a
   network that isn't enabled server-side is dead weight, and an enabled
   network with no adapter in the binary silently contributes nothing. Ask the
   publisher which networks are enabled (or read their config via the CloudX
   MCP/CLI `config/show` if they have it set up). Never guess and never
   default to "all".
3. Fetch the platform's integration overview page, the pages for each ad format
   the user wants (default: ask, or start with the formats the app already
   shows), and the adapter overview page for every network in the adapter set.
   `references/doc-map.md` explains which page stems answer which questions.
4. Read the playbooks selected in Detect.
5. Present a short plan: dependencies to add, files to create/modify, formats to
   implement, playbook considerations. Confirm with the user if anything is
   ambiguous (formats, networks, coexistence vs replacement intent).

### Phase 3 — Integrate

Implement from the fetched docs pages only:

- Add repositories/dependencies exactly as the integration overview specifies.
- Apply each enabled adapter's overview page **in full** — beyond the
  dependency line, adapter pages can require additional Maven repositories,
  manifest/Info.plist entries, an SDK-track choice, or native asset/view
  requirements. Skipping these is a build or runtime failure, not an optional
  extra.
- Initialize the SDK where the docs say to, with the app key.
- Implement each ad format per its docs page, including listeners and lifecycle
  (destroy/cleanup) requirements.
- Apply every selected playbook's guidance (init ordering relative to a CMP,
  coexistence wiring, build-system adjustments).
- Match the project's existing code style and language (Kotlin vs Java,
  Swift vs Objective-C).

### Phase 4 — Build-verify

Run the project's own build (Gradle assemble, Xcode build, `flutter build`,
etc.). Fix compile errors by re-reading the fetched docs pages — a signature
mismatch means you mis-read or the docs page moved, never a reason to guess.
Repeat until the build passes. If the build cannot be run in this environment,
say so explicitly in the report instead of claiming verification.

### Phase 5 — Audit

Before reporting, verify against the code you just wrote (and re-fetch docs
pages if uncertain):

- Init happens once, in the documented location, before any ad load.
- Every created ad object has its documented lifecycle handled.
- Load/show error callbacks are handled; fullscreen ads check readiness before
  showing.
- Every installed adapter's docs-page requirements are fully met (extra
  repositories, manifest/Info.plist entries, native view requirements), and
  the adapter set matches the networks enabled in the publisher's dashboard
  config.
- If the app has an existing mediation stack: its code paths are untouched and
  still reachable (coexistence), or fully removed (migration) — per the intent
  established in Detect.
- Privacy: a CMP writes IAB consent strings before ads load, per the docs
  privacy guidance and the `consent-and-cmp` playbook if selected.
- No placeholder credentials silently left behind — every placeholder is listed
  in the report.

### Phase 6 — Report

Summarize: files changed (with paths), formats implemented, networks/adapters
enabled, playbooks applied, build result, and required follow-ups (replace
placeholder app key / ad unit IDs, register the app's bundle ID in the CloudX
dashboard, CMP configuration). Link the docs pages you used.

## Auditing an existing integration

For "check / audit my existing CloudX integration" without new integration
work, use the `cloudx-audit` skill instead (Detect + Audit phases only).
