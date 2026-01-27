# Scrape (v2)

Scrape fetches a **single URL** and returns the page content in one or more formats (Markdown by default). You can optionally run **browser actions** (click, scroll, wait, execute JS, etc.) before content is captured.

## HTTP request

- **Method:** `POST`
- **Path:** `/v2/scrape`
- **Base URL:** `https://api.firecrawl.dev`
- **Auth:** `Authorization: Bearer <API_KEY>`

## Request body (what you send)

### Required
- `url` (string, URL): the page to scrape.

### Common scraping options
These come from `ScrapeOptions`:

- `formats` (array; default: `[{"type":"markdown"}]`): which outputs to include.
  - `markdown`, `summary`, `html`, `rawHtml`, `links`, `images`
  - `screenshot` (options include `fullPage`, `quality`, `viewport {width,height}`)
  - `json` (LLM-powered structured extraction; supports `schema` (JSON Schema) and `prompt`)
  - `changeTracking` (compare against previous scrapes; supports `modes` = `git-diff` and/or `json`, plus `schema`, `prompt`, `tag`)
  - `branding` (extracts brand/tokens like colors/fonts/etc when requested)
- `onlyMainContent` (boolean; default `true`): attempt to return main article content (remove nav/header/footer).
- `includeTags` / `excludeTags` (arrays of strings): include/exclude specific tags in the output.
- `maxAge` (ms; default 2 days): allow cached responses if the cached page is newer than this.
- `headers` (object): custom request headers (cookies, user-agent, etc.).
- `waitFor` (ms; default `0`): additional delay before content is fetched (in addition to Firecrawl’s smart wait).
- `mobile` (boolean; default `false`): emulate a mobile device.
- `skipTlsVerification` (boolean; default `true`): skip TLS certificate verification.
- `timeout` (ms; default `30000`, max `300000`): request timeout.

### File parsing (notably PDFs)
- `parsers` (array; default includes `pdf`):
  - When `pdf` is included, Firecrawl extracts PDF text into Markdown and bills **per page**.
  - If you send an **empty array**, the PDF is returned as **base64** with a **flat** cost (per the docs).

### Browser actions (optional)
- `actions` (array): steps performed in a real browser **before** the scrape snapshot is taken. Supported action types include:
  - `wait` (by milliseconds or by CSS selector)
  - `click` (optionally `all: true`)
  - `write` (type text; typically after focusing an element)
  - `press` (keyboard key)
  - `scroll`
  - `screenshot`
  - `scrape` (capture current page HTML at that point)
  - `executeJavascript`
  - `pdf` (generate a PDF)

See: https://docs.firecrawl.dev/advanced-scraping-guide#actions-actions

### Location / proxy / filtering
- `location` (object): `country` (ISO-3166-1 alpha-2) and `languages` (Accept-Language style).
- `removeBase64Images` (boolean; default `true`): replaces base64 images with placeholders to keep output small.
- `blockAds` (boolean; default `true`): enables ad-blocking and cookie popup blocking.
- `proxy` (`basic` | `stealth` | `auto`; default `auto`):
  - `stealth` is more reliable for hard targets but can cost more credits.
  - `auto` retries with stealth only if needed.
- `storeInCache` (boolean; default `true`): controls whether the page is stored in Firecrawl’s index/cache (some sensitive options may force this false).

### Data retention
- `zeroDataRetention` (boolean; default `false`): enables zero data retention **if your account has it enabled** (docs say to contact Firecrawl support to enable).

## Response (what you get back)

On success (`200`), the response is a `ScrapeResponse` object:

- `success` (boolean)
- `data` (object) which may include, depending on `formats`:
  - `markdown` (string)
  - `summary` (string|null)
  - `html` (string|null)
  - `rawHtml` (string|null)
  - `links` (string[])
  - `screenshot` (string|null): a URL (expires after 24 hours)
  - `actions` (object|null): results from your browser actions (`screenshots`, `scrapes`, `javascriptReturns`, `pdfs`)
  - `metadata` (object): title/description/language/keywords/statusCode/error, plus other extracted meta
  - `warning` (string|null): warnings related to LLM extraction
  - `changeTracking` (object|null): present if the `changeTracking` format is requested

## Errors

- `402` payment required
- `429` rate limit exceeded
- `500` server error
