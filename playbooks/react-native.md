---
applies_to: [react-native]
signals: ["always load for React Native projects", "react-native in package.json", "Expo config"]
last_verified: 2026-08-03
status: stub
---

# React Native specifics

> Stub — to be seeded from real support cases. The React Native integration
> docs page is the source of truth for package installation and API usage
> (`en/react-native/integration.md`).

React Native-specific knowledge to capture here as cases surface:

- Autolinking edge cases and manual-link fallbacks.
- Expo: managed vs bare workflow support and config-plugin needs.
- New-architecture (Fabric/TurboModules) compatibility notes.
- Native-side steps that JS-only developers commonly miss (Podfile install,
  Gradle sync, native init timing).
