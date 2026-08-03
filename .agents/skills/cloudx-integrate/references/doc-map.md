# CloudX docs map

Index: `https://docs.cloudx.io/llms.txt` — fetch it first; it lists every page
with a one-line description. Every listed page is raw markdown at its `.md` URL.
This file names the stable page *stems* and when to fetch them. It never
restates page content; if a stem here disappears from llms.txt, this file is
wrong and must be updated (CI checks this).

## Per-platform stems

`<platform>` is one of `android`, `ios`, `react-native`, `flutter`, `unity`.

| Stem | Fetch when |
|---|---|
| `en/<platform>/integration.md` | Always, first. Setup, current version + dependency coordinates, initialization, core features. |
| `en/<platform>/ad-formats/<format>.md` | Per ad format you implement (`banner-mrec`, `interstitial`, `rewarded`, `app-open`, `native`). Flutter: formats are covered in the integration overview. |
| `en/<platform>/adapters/<network>/overview.md` | Per bidder network the publisher enables (Android/iOS). Unity uses `en/unity/adapters/<network>.md`. Lists the adapter's supported formats and its dependency. |
| `en/<platform>/integrations/first-look.md` | Publisher keeps an existing mediation stack and tries CloudX first with fallback (Android/iOS today). Pairs with the `coexist-*` playbooks. |
| `en/<platform>/trusted-arbiter.md` | Publisher wants CloudX bid comparison against third-party bids. |
| `en/<platform>/changelog.md` | Diagnosing behavior differences between SDK versions, or confirming when an API changed. |
| `en/<platform>/connectors/<name>/overview.md` | Revenue-connector setup (e.g. AppsFlyer; Android/iOS). |

## Cross-platform stems

| Stem | Fetch when |
|---|---|
| `en/ad-formats/index.md` and `en/ad-formats/<format>.md` | Which networks support which format — choosing adapters. |
| `en/ad-formats/caching.md` | Fill/caching behavior questions and load-retention best practices. |
| `en/networks/<network>.md` | Dashboard-side bidder configuration (account credentials, placements). |
| `en/dashboard/apps.md`, `en/dashboard/ad-units.md`, `en/dashboard/testing.md` | Publisher needs to create apps/ad units or register test devices. |
| `en/mcp/installation.md`, `en/mcp/index.md` | Publisher wants the CloudX MCP server (reporting, docs search) in their agent. |
| `en/changelog.md` | Combined release history across products. |
