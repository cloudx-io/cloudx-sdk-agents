---
name: cloudx-audit
description: Audit an existing CloudX SDK integration in a publisher app for correctness, staleness, lifecycle, coexistence, and privacy issues. Use when asked to check, audit, review, or validate a CloudX integration that already exists, or after upgrading the CloudX SDK version.
---

# CloudX Integration Audit

Audit the CloudX integration already present in this app. Do not add new
integration work — for that, use `cloudx-integrate`.

**Iron rule:** never judge the integration against APIs from memory. Fetch the
current docs first (`https://docs.cloudx.io/llms.txt`, then the platform pages —
see `../cloudx-integrate/references/doc-map.md`) and diff the code against what
the docs say *today*. An integration written against an older SDK may compile
and still be wrong or incomplete; the platform changelog page shows what changed.

## Steps

1. **Detect** — platform, CloudX SDK dependency and adapters present, ad formats
   used, existing mediation SDKs, CMP tooling. Match playbook signals in
   `../cloudx-integrate/references/playbook-index.md` and read the playbooks
   that apply.
2. **Fetch** — the platform integration overview, the ad-format page for each
   format the app uses, the platform changelog, and adapter pages for adapters
   present.
3. **Diff code against current docs:**
   - Dependency coordinates and adapter set vs the current documented ones.
   - Initialization: documented location, once, before ad loads, correct config.
   - Each ad format: creation, listeners, readiness checks, show requirements,
     lifecycle/destroy handling per the current docs page.
   - Removed/renamed APIs still referenced (changelog is the evidence).
4. **Coexistence** — if another mediation stack is present: both init paths
   intact, fallback or first-look wiring per the platform's first-look docs
   page, no circular loading, per `coexist-mediation.md`.
5. **Privacy** — CMP writes IAB consent strings before ads load; no usage of
   privacy APIs the changelog marks removed; consent forwarded to any
   coexisting mediation SDK (per `consent-and-cmp.md`).
6. **Report** — findings ranked by severity: breaks now / breaks on upgrade /
   revenue risk / hygiene. Each finding cites the file:line and the docs page
   that contradicts it. End with the SDK-version gap (dependency present vs
   current documented version) and the changelog entries in between.
