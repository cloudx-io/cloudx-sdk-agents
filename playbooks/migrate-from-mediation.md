---
applies_to: [android, ios, unity, react-native, flutter]
signals: ["user intent: replace / remove / migrate off an existing mediation stack", "\"switch from MAX/LevelPlay/AdMob to CloudX\""]
last_verified: 2026-08-03
---

# Migrating off an existing mediation stack

> Content rule: this file holds only knowledge absent from docs.cloudx.io.
> All CloudX-side setup comes from the platform docs pages.

## Confirm the intent is really migration

"Move to CloudX" from a publisher usually means *start monetizing through
CloudX*, not *delete my mediation today*. Recommend the staged path unless the
user explicitly confirms removal:

1. **Stage 1 — coexist:** integrate CloudX first-look with the existing stack
   as fallback (see the matching `coexist-*` playbook and the platform's
   first-look docs page). Run both, compare in the dashboard.
2. **Stage 2 — remove:** once the publisher is satisfied, strip the old stack.

Jumping straight to stage 2 forfeits the revenue comparison and makes any
regression unrecoverable without a re-integration.

## When actually removing the old stack

Removal is more than deleting the dependency:

- **Inventory first.** List every placement/ad-unit the old stack serves and
  map each to a CloudX ad unit *before* touching code. Anything unmapped goes
  dark silently.
- **Delete the whole surface:** dependencies (including the old stack's
  mediation adapters — they bundle partner SDKs that will otherwise linger),
  manifest/Info.plist keys (app IDs, activities), init calls, listeners,
  ProGuard rules, and any remote-config flags that referenced the old stack.
- **Partner SDK survivors:** if the app used a partner network both via the old
  mediation and via a CloudX adapter, the partner SDK stays — only its old
  mediation adapter goes. Get the dependency graph, don't grep-and-delete.
- **Consent glue:** CMP-to-mediation forwarding code for the old stack comes
  out; CMP IAB output stays (CloudX consumes it — see `consent-and-cmp.md`).
- **Kill switches / remote flags:** publishers often gate mediation behind
  remote config. Leaving a dead flag that can "re-enable" a removed SDK is a
  production incident waiting; remove the flag path too.

## Verification after removal

Build must pass with the old SDK absent; grep for the old stack's class
prefixes to catch stragglers; run the app and confirm no init-time crash from
a leftover manifest entry; confirm every inventoried placement now loads via
CloudX in the ad-unit report (`en/dashboard/ad-units.md`).
