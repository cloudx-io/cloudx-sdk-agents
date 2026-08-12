---
applies_to: [android, ios, unity, react-native, flutter]
signals: ["any existing mediation SDK detected: AppLovin MAX, LevelPlay/ironSource, Google AdMob/Ad Manager, or another mediator", "publisher wants CloudX alongside existing monetization", "publisher names a setup shape: first look, parallel, Trusted Arbiter/TPA, standalone/full platform, or asks about post-bid"]
last_verified: 2026-08-12
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

## Setup shapes

Publishers with an existing mediator almost never remove it on day one. Decide
in this order:

1. If the intent is to *remove* the mediator, switch to
   `migrate-from-mediation.md`.
2. Enumerate the setup modes the platform actually offers: the pages under
   `en/<platform>/integrations/` plus the `trusted-arbiter` family in
   `llms.txt`. The list below names today's shapes, but the docs index is the
   source of truth — the set is open and availability varies by platform; a
   mode not listed there for the platform doesn't exist for it yet.
3. Choose a shape **per ad format, not per app** — mixed setups are normal
   (e.g. first look on interstitials, standalone banners, rewarded untouched).
   Ask the publisher format by format if unstated, presenting each mode's own
   one-line description from `llms.txt`. Record the resulting format → shape
   matrix; integration, audit, and reporting all key off it.

Today's shapes:

- **First look** — CloudX gets the first chance at an impression; on no-fill,
  the existing mediator's placement serves as before. Wiring per the platform's
  `integrations/first-look.md` page — fetch it; it is the source of truth.
- **Parallel (Trusted Arbiter)** — CloudX-controlled arbitration compares a
  CloudX bid with the incumbent's bid for the same slot and shows the winner.
  Wiring per the platform's `trusted-arbiter.md` page — fetch it; it is the
  source of truth, including how revenue is reported in both directions.
- **Standalone (per-format split)** — CloudX exclusively owns selected formats
  (commonly banner/MREC/native) while the mediator keeps the rest. No
  cross-stack fallback wiring for CloudX-owned formats; each side runs its own
  placements. (Dedicated docs page pending — until it ships, this paragraph is
  the field guidance.)

**Decision-point guardrail.** CloudX must sit at or ahead of the decision
point for any impression it competes on. If the publisher's architecture runs
an auction *behind* CloudX (post-bid), or the bid comparison happens inside a
publisher-controlled framework, stop and surface it — that arrangement is
unsupported; the supported parallel mechanism is Trusted Arbiter.

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
- **iOS delegate selector collisions.** Mediator and CloudX delegate
  protocols can declare same-named Objective-C selectors (observed with
  AppLovin MAX's ad-view delegate vs CloudX's banner delegate). A single class
  conforming to both fails to compile or dispatches ambiguously — give each
  SDK its own delegate/listener object, which the parallel-objects rule above
  requires anyway.
- **Header-bidding companions stay put.** Amazon APS or similar companions
  wired into the mediator remain wired to the mediator. Do not route them
  through CloudX.

## Mediator notes

- **Google (AdMob / Ad Manager):** besides first-look coexistence, the docs
  offer an AdMob-waterfall adapter path (`adapters/googlewaterfall` pages) that
  serves existing AdMob waterfall placements through CloudX. Fetch its overview
  and put the choice to the publisher before wiring first-look.
  AdMob does not price an ad before the impression; comparing against an
  estimated AdMob price is dashboard-side configuration — never encode an
  estimated eCPM in app code as a bid.

## Reporting the outcome

State the final format → shape matrix explicitly — which formats got
first-look treatment, which run through the arbiter, which are standalone
CloudX, and which remain untouched mediator placements; point the publisher at
the dashboard's mediation-comparison view for the revenue read
(`en/dashboard/total-revenue.md`).
