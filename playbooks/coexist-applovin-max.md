---
applies_to: [android, ios, unity, react-native, flutter]
signals: ["com.applovin gradle dependency", "applovin.sdk.key manifest entry", "AppLovinSdk / MAX* symbols", "AppLovinSDK pod", "AppLovin MAX Unity plugin"]
last_verified: 2026-08-03
---

# Coexisting with AppLovin MAX

> Content rule: this file holds only knowledge absent from docs.cloudx.io.
> For the supported first-look/fallback pattern itself, fetch the platform's
> `integrations/first-look.md` docs page — it is the source of truth for the
> wiring. This playbook covers what the docs page assumes you already know
> about a real MAX app.

## The shape of the engagement

Publishers on MAX almost never want MAX removed on day one. The standard motion
is **first look**: give CloudX the first chance at an impression and fall back
to the existing MAX placement when CloudX has no fill. Revenue comparison comes
from running both and reading the dashboard (`en/dashboard/total-revenue.md`),
not from ripping anything out. If the user actually wants MAX gone, switch to
`migrate-from-mediation.md`.

## Things a MAX app already decided for you

- **Init order:** MAX apps initialize AppLovin in `Application.onCreate` /
  `didFinishLaunching`. Initialize CloudX alongside it, not inside MAX
  callbacks — the two SDKs are independent and neither should gate the other's
  startup.
- **The MAX ad-object lifecycle stays MAX's.** Do not wrap, subclass, or reuse
  MAX ad views/listeners for CloudX ads. Parallel objects, parallel listeners;
  the only shared logic is the decision of which one to show.
- **Fallback triggers belong in load-failure callbacks, not show-failure.** By
  show time the impression opportunity is already committed; falling back on a
  failed show double-counts the opportunity in both stacks' metrics.
- **Never chain fallbacks circularly** (CloudX fails → MAX fails → retry
  CloudX → …). One fallback hop, then respect the retry cadence the docs'
  caching page describes.

## Collision points to check

- **Duplicate network SDKs.** MAX mediation adapters bundle the same partner
  SDKs CloudX adapters bind to (Meta, Vungle, InMobi, Mintegral, …). The
  partner SDK resolves to one version per app; the MAX adapter and CloudX
  adapter may pin different ranges. On Android watch the Gradle dependency
  resolution report; on iOS CocoaPods will fail loudly, SPM+pods mixes fail
  quietly. Resolve by aligning on the newest version both adapters accept —
  each CloudX adapter's docs page states its supported partner-SDK range.
- **Banner auto-refresh fighting.** If a MAX banner and a CloudX banner share a
  screen slot in a fallback arrangement, stop the hidden one's auto-refresh —
  both refreshing in the background bids/renders twice for one visible slot.
- **Consent must reach both stacks.** CloudX reads IAB strings from the
  platform's standard storage; MAX has its own privacy API surface. A CMP
  configured only for MAX often leaves the IAB strings unwritten (or vice
  versa). See `consent-and-cmp.md`.
- **Amazon APS / other header-bidding companions** hanging off MAX stay wired
  to MAX. Do not try to route them through CloudX.

## Reporting the outcome

In the final report, state explicitly which placements got first-look treatment
and which are untouched MAX placements, and point the publisher at the
dashboard's mediation-comparison view for the revenue read.
