---
applies_to: [android, ios, unity, react-native, flutter]
signals: ["com.google.android.gms.ads.APPLICATION_ID manifest entry", "GADApplicationIdentifier in Info.plist", "Google Mobile Ads / Ad Manager symbols"]
last_verified: 2026-08-03
status: stub
---

# Coexisting with Google (AdMob / Ad Manager)

> Stub — to be seeded from real support cases. Until then, follow the general
> coexistence guidance in `coexist-applovin-max.md` and the platform's
> `integrations/first-look.md` docs page, substituting Google Mobile Ads APIs.
> Note the docs also cover a CloudX AdMob-waterfall adapter path
> (`adapters/googlewaterfall`) — fetch its overview page before deciding
> between coexistence and adapter-based serving.

Google-specific knowledge to capture here as cases surface:

- Choosing between first-look coexistence and the googlewaterfall adapter.
- GMA vs GMA Next-Gen SDK differences that affect coexistence.
- Manifest/Info.plist app-ID requirements interacting with CloudX-side setup.
