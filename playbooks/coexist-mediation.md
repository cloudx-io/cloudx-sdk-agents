---
applies_to: [android, ios, unity, react-native, flutter]
signals: ["any existing mediation SDK detected: AppLovin MAX, LevelPlay/ironSource, Google AdMob/Ad Manager, or another mediator", "publisher wants CloudX alongside existing monetization"]
last_verified: 2026-08-03
---

# Coexisting with an existing mediation stack

> Content rule: this file holds only knowledge absent from docs.cloudx.io.
> The supported first-look/fallback wiring is documented on the platform's
> `integrations/first-look.md` docs page — fetch it; it is the source of truth.
> This playbook covers the mediator-agnostic pattern around it.

## Identify the mediator, then treat its APIs like CloudX's

Detection signals (dependency coordinates, manifest/Info.plist keys, symbols)
tell you *which* mediator is present — see `playbook-index.md`. From there, the
iron rule extends to the mediator: **do not write its init, placement, or
privacy APIs from memory.** Mediator SDKs move as fast as CloudX does; look up
the detected mediator's current documentation live before touching its code
paths.

## The two engagement shapes

Publishers with an existing mediator almost never remove it on day one. The
motion is one of:

- **First look:** CloudX gets the first chance at an impression; on no-fill,
  the existing mediator's placement serves as before. Per-placement wiring —
  the platform's first-look docs page covers it.
- **Parallel:** both stacks run live on different placements (or a traffic
  split), and the publisher compares revenue in the dashboard
  (`en/dashboard/total-revenue.md`).

Ask which shape the publisher wants if it isn't stated. If they actually want
the mediator *removed*, switch to `migrate-from-mediation.md`.

## Universal rules

- **Init independence.** Initialize CloudX alongside the mediator, not inside
  its callbacks — neither SDK should gate the other's startup.
- **Parallel objects, parallel listeners.** Do not wrap, subclass, or reuse the
  mediator's ad views/listeners for CloudX ads. The only shared logic is the
  decision of which ad to show.
- **Fallback triggers belong in load-failure callbacks, not show-failure.** By
  show time the impression opportunity is committed; falling back on a failed
  show double-counts the opportunity in both stacks' metrics.
- **One fallback hop, never circular** (CloudX fails → mediator fails → retry
  CloudX → …). After the hop, respect the retry cadence described on the docs
  caching page (`en/ad-formats/caching.md`).

## Collision points to check

- **Duplicate partner SDKs.** The mediator's adapters bundle the same partner
  SDKs CloudX adapters bind to (Meta, Vungle, InMobi, Mintegral, …). One
  version of each partner SDK resolves per app; the two adapter sets may pin
  different ranges. Android: read the Gradle dependency-resolution report;
  iOS: CocoaPods fails loudly, SPM+pods mixes fail quietly. Align on the
  newest version both accept — each CloudX adapter's docs page states its
  supported partner-SDK range; check the mediator's adapter requirements live.
- **Banner auto-refresh fighting.** If a mediator banner and a CloudX banner
  share a screen slot in a fallback arrangement, stop the hidden one's
  auto-refresh — two background refreshers bid/render twice for one visible
  slot.
- **Consent must reach both stacks.** CloudX reads IAB strings from platform
  storage; most mediators additionally have their own privacy API surface. A
  CMP configured for only one stack leaves the other non-compliant or
  under-monetizing. See `consent-and-cmp.md`; look up the mediator's current
  consent API live.
- **Header-bidding companions stay put.** Amazon APS or similar companions
  wired into the mediator remain wired to the mediator. Do not route them
  through CloudX.

## Mediator notes

- **Google (AdMob / Ad Manager):** besides first-look coexistence, the docs
  offer an AdMob-waterfall adapter path (`adapters/googlewaterfall` pages) that
  serves existing AdMob waterfall placements through CloudX. Fetch its overview
  and put the choice to the publisher before wiring first-look.

## Reporting the outcome

State explicitly which placements got first-look treatment, which run parallel,
and which remain untouched mediator placements; point the publisher at the
dashboard's mediation-comparison view for the revenue read.
