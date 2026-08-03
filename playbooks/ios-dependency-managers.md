---
applies_to: [ios]
signals: ["always load for iOS projects", "Podfile vs Package.swift", "use_frameworks!", "static vs dynamic linking"]
last_verified: 2026-08-03
---

# iOS dependency managers

> Content rule: this file holds only knowledge absent from docs.cloudx.io.
> Pod names, SPM URLs, and supported install methods come from the iOS
> integration docs page — fetch it; never write them from memory.

## Pick the project's existing manager

Never introduce a second dependency manager. If the app uses CocoaPods, add the
pods; if SPM, add the packages; if both exist (common in transition-era apps),
follow where the other ad/analytics SDKs already live — mixing managers for
SDKs that share transitive partner dependencies is how duplicate-symbol errors
happen.

## CocoaPods specifics

- **`use_frameworks!` vs static:** partner ad SDKs are a mix of static and
  dynamic binaries; the Podfile's linkage mode interacts with that. If `pod
  install` errors about transitive dependencies with static binaries, the fix
  is usually `use_frameworks! :linkage => :static` — but that flips linkage for
  every pod, so check the app's other pods tolerate it before changing.
- After editing the Podfile always run `pod install` (not `update`) and build
  the `.xcworkspace`. If the repo state is old, `pod repo update` first —
  "pod not found" for a pod the docs page names usually means a stale local
  specs cache, not a wrong name.
- **Apple-silicon simulator link errors** (arm64-simulator slices missing from
  a partner binary) surface here. Workaround is building on a device target or
  excluding arch for simulator — surface it to the publisher rather than
  silently changing build settings.

## SPM specifics

- Add packages at the *project* level and check the products are attached to
  the app target — SPM happily resolves a package without linking it anywhere,
  which then "integrates" with zero symbols available.
- Mixed SPM + CocoaPods apps: if a partner SDK arrives via both routes
  (CloudX adapter one way, existing mediation the other), you get duplicate
  symbols at link or, worse, ODR violations at runtime. Consolidate that
  partner to a single route.

## Xcode project hygiene

- Info.plist ad-network entries (e.g. SKAdNetwork identifiers, ATT usage
  description) are listed by the docs pages per network — merge, don't
  overwrite, the app's existing entries.
- If the app has no `.xcworkspace` and the docs assume CocoaPods, that's the
  signal the publisher is SPM-only; don't create a Podfile for one SDK.
