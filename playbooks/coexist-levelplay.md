---
applies_to: [android, ios, unity]
signals: ["com.ironsource / com.unity3d.mediation gradle dependencies", "IronSource / LevelPlay symbols", "IronSourceSDK pod"]
last_verified: 2026-08-03
status: stub
---

# Coexisting with LevelPlay (ironSource)

> Stub — to be seeded from real support cases. Until then, follow the general
> coexistence guidance in `coexist-applovin-max.md` (init independence,
> fallback on load failure only, no circular fallback, duplicate partner-SDK
> resolution, consent to both stacks) and the platform's
> `integrations/first-look.md` docs page, substituting LevelPlay's own APIs.

LevelPlay-specific knowledge to capture here as cases surface:

- LevelPlay init/placement model differences that affect first-look wiring.
- ironSource adapter partner-SDK version collisions seen in the field.
- Unity: interactions with the LevelPlay Unity plugin's dependency management.
