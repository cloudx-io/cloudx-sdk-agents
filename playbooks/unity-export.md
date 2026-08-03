---
applies_to: [unity]
signals: ["always load for Unity projects", "ProjectSettings/", "ExternalDependencyManager (EDM4U)", "custom Gradle / Xcode templates"]
last_verified: 2026-08-03
status: stub
---

# Unity export quirks

> Stub — to be seeded from real support cases. The Unity integration docs page
> is the source of truth for package installation and per-network setup
> (`en/unity/integration.md`, `en/unity/adapters/<network>.md`).

Unity-specific knowledge to capture here as cases surface:

- EDM4U resolution behavior and conflicts with other plugins' dependencies.
- Custom `mainTemplate.gradle` / `gradleTemplate.properties` interactions.
- iOS post-process build steps and Podfile generation from Unity.
- IL2CPP stripping and link.xml needs, if any are observed.
