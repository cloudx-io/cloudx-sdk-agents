---
applies_to: [android]
signals: ["always load for Android projects", "Groovy vs Kotlin DSL", "libs.versions.toml", "minifyEnabled true", "multi-module app"]
last_verified: 2026-08-03
---

# Android build-system variants

> Content rule: this file holds only knowledge absent from docs.cloudx.io.
> Dependency coordinates and required repositories come from the Android
> integration docs page — fetch it; never write coordinates from memory.

## Translate the docs to the project's dialect

The docs show one canonical dependency style. Real projects vary; translate,
don't paste:

- **Groovy DSL** (`build.gradle`): quotes and no parentheses differ from the
  KTS examples. Keep the project's existing style.
- **Version catalogs** (`gradle/libs.versions.toml`): if the project uses a
  catalog, add the CloudX artifacts there and reference `libs.` aliases in the
  module build file — dropping raw coordinates into a catalog-using module will
  pass review nowhere.
- **Repository declaration location:** newer projects centralize repositories
  in `settings.gradle(.kts)` `dependencyResolutionManagement`; older ones use
  root or module-level `repositories`. Adding a repository in the wrong place
  either errors (`FAIL_ON_PROJECT_REPOS`) or silently does nothing. Match the
  project's existing declaration site.
- **Multi-module apps:** dependencies go in the module that shows ads (usually
  `:app`), init goes in the module owning the `Application` class — these are
  not always the same module.

## Minification (R8/ProGuard)

- If `minifyEnabled true` on release builds: modern AARs ship consumer rules,
  so no manual keep rules should be needed — but verify by building the
  *release* variant, not just debug. A debug-only build "verification" on a
  minified app is not verification.
- Symptom of missing/broken keep rules: runtime `ClassNotFoundException` /
  reflection failures in release only, typically in adapter code paths. Check
  the partner network's own ProGuard requirements too — partner SDKs pulled in
  by adapters have their own rules.

## Other recurring snags

- **minSdk conflicts:** if the app's `minSdk` is below what the SDK or a
  partner adapter requires, Gradle manifest merger fails with a clear message —
  raise `minSdk` or drop that adapter; don't add `tools:overrideLibrary`, which
  trades a build error for runtime crashes on old devices.
- **Duplicate-class failures** after adding adapters usually mean the app
  already bundled a partner SDK directly (or via another mediation stack) at a
  different version. Resolve to a single version; see the coexist playbooks.
- **AGP version spread:** projects on old Android Gradle Plugin versions can
  fail to consume newer AARs. The error is obscure (`AAR metadata check`); the
  fix is an AGP upgrade, and that is a decision to surface to the publisher,
  not to make silently.
