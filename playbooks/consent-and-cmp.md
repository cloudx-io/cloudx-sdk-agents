---
applies_to: [android, ios, unity, react-native, flutter]
signals: ["UMP / Usercentrics / Sourcepoint / OneTrust / Didomi artifacts", "IABTCF_* / IABGPP_* / IABUSPrivacy_* reads or writes", "publisher mentions GDPR / CCPA / consent"]
last_verified: 2026-08-03
---

# Consent and CMPs

> Content rule: this file holds only knowledge absent from docs.cloudx.io.
> The SDK's privacy behavior (which consent signals it reads and how it applies
> them) is documented on the platform integration page — fetch it; don't trust
> this file or memory for signal names.

## The one ordering rule that matters

The CMP must have written its consent state **before ads load** — not
necessarily before the SDK initializes. In practice the safe pattern is: run
the CMP flow at app start, and gate the *first ad load* (not SDK init) on the
CMP's completion callback. Publishers routinely get this wrong in two
directions:

- Gating SDK init on consent: harmless but adds latency for nothing if the
  docs say the SDK reads consent at request time.
- Loading ads immediately at startup while the CMP dialog is still on screen:
  the first session's ads go out with absent/denied consent and monetize
  poorly. This shows up later as "revenue is bad on day-0 users."

## CMP quirks seen in the field

- **CMPs write IAB strings to the platform-standard storage** (SharedPreferences
  on Android, UserDefaults on iOS) — that is the whole integration contract
  with CloudX. If the CMP is configured in a "custom consent" mode that skips
  IAB string output, CloudX sees nothing. Verify strings actually appear on
  device after the consent flow, don't assume.
- **Google UMP** writes TCF strings but its consent scope is Google-centric;
  check the vendor list configuration actually includes the networks the
  publisher monetizes with, or non-Google bidders get blanket-denied.
- **Wrapper platforms** (Unity/RN/Flutter CMP plugins) sometimes cache consent
  in the wrapper layer and only sync to native storage on the next launch.
  Symptom: consent looks granted in the CMP's own debug UI but the IAB strings
  on the native side are stale until restart.
- **Coexisting mediation SDKs have their own privacy APIs** in addition to IAB
  strings. When CloudX runs alongside MAX/LevelPlay/GMA, confirm the CMP (or
  explicit glue code) feeds those SDKs too — a consent fix applied only to
  CloudX leaves the fallback stack non-compliant.

## Children's apps

Apps in children's categories need the CMP configured for the relevant
child-privacy regime (COPPA etc.); CloudX follows the signals the CMP emits.
Do not hand-roll child-directed flags in app code — keep the CMP as the single
authority and verify what it writes.

## What to verify in the Audit phase

1. A CMP exists and its consent flow actually runs before the first ad load.
2. IAB strings are present in platform storage on a device/emulator after the
   flow (grep for reads is not enough — check runtime state when possible).
3. Consent changes mid-session take effect per the docs' stated behavior.
4. Coexisting mediation SDKs receive consent through their own APIs.
