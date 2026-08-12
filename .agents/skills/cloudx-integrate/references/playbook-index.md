# Playbook dispatch

During Detect, match these signals against the project. Load every playbook
whose signal matches; skip the rest. Playbooks live in `playbooks/` at the
repository root.

| Signal in the project | Playbook |
|---|---|
| Any existing mediation SDK present — AppLovin MAX (`com.applovin` deps, `applovin.sdk.key` manifest entry, `AppLovinSdk`/`MAX` symbols, `AppLovinSDK` pod), LevelPlay/ironSource (`com.ironsource`/`com.unity3d.mediation` deps, `IronSource`/`LevelPlay` symbols, `IronSourceSDK` pod), Google AdMob/Ad Manager (`com.google.android.gms.ads.APPLICATION_ID` manifest entry, `GADApplicationIdentifier` in Info.plist, Google Mobile Ads symbols), or another mediator | `coexist-mediation.md` — note which mediator was detected; the playbook is mediator-agnostic and instructs looking up the mediator's own current APIs live |
| User intent is *replace* an existing mediation stack (not add alongside) | `migrate-from-mediation.md` |
| User names a setup shape or mechanism — "first look", "parallel", "Trusted Arbiter"/"TPA", "standalone"/"full platform" — or asks about post-bid arrangements | `coexist-mediation.md` — note the requested shape; its setup-shapes section maps each shape to the right docs page and holds the decision-point guardrail |
| CMP present: UMP, Usercentrics, Sourcepoint, OneTrust, Didomi artifacts; `IABTCF_`/`IABGPP_`/`IABUSPrivacy_` reads/writes | `consent-and-cmp.md` |
| Android project at all (always load for Android): Groovy vs KTS DSL, `libs.versions.toml`, `minifyEnabled true` | `android-build-variants.md` |
| iOS project at all (always load for iOS): `Podfile` vs `Package.swift`, `use_frameworks!`, static/dynamic linking | `ios-dependency-managers.md` |
| Unity project (always load for Unity): `ProjectSettings/`, EDM4U (`ExternalDependencyManager`), custom Gradle/Xcode templates | `unity-export.md` |
| React Native project (always load for RN): `react-native` in `package.json`, `app.json`/Expo config | `react-native.md` |
| Flutter project (always load for Flutter): `pubspec.yaml` | `flutter.md` |

Multiple playbooks commonly apply (e.g. an Android app on MAX with a CMP loads
three). If two playbooks disagree, the more specific scenario wins and the
conflict should be surfaced in the report.
