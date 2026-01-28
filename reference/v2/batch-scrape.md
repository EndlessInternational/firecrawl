# Batch Scrape (v2)

Batch Scrape creates an **asynchronous job** to scrape **multiple URLs** using the same scrape options. You typically:

1. `POST /v2/batch/scrape` with a list of URLs (and options)
2. Poll `GET /v2/batch/scrape/{id}` until `status` becomes `completed` (or `failed`)
3. Optionally call `GET /v2/batch/scrape/{id}/errors` for per-URL failures
4. Optionally cancel with `DELETE /v2/batch/scrape/{id}`

## HTTP request

- **Method:** `POST`
- **Path:** `/v2/batch/scrape`
- **Auth:** `Authorization: Bearer <API_KEY>`

## Request body

### Required
- `urls` (string[]): list of URLs to scrape.

### Batch-specific options
- `webhook` (object): receive events as the job runs.
  - `url` (string, required): the URL to send webhook events to.
  - `headers` (object): headers to send to webhook URL.
  - `metadata` (object): custom metadata included in all webhook payloads.
  - `events` (string[]): which events to send (`started`, `page`, `completed`, `failed`).
- `maxConcurrency` (integer): maximum number of concurrent scrapes. If not specified, adheres to team's concurrency limit.
- `ignoreInvalidURLs` (boolean, default `true`): invalid URLs ignored instead of failing entire request.

### Scrape options (applied to every URL)
- `formats` (array, default `[markdown]`): output formats (`markdown`, `summary`, `html`, `rawHtml`, `links`, `images`, `screenshot`, `json`, `changeTracking`, `branding`).
- `onlyMainContent` (boolean, default `true`): only return main content excluding headers, navs, footers.
- `includeTags` / `excludeTags` (string[]): tags to include/exclude in output.
- `maxAge` (integer, default `172800000`): returns cached version if younger than this age in milliseconds.
- `headers` (object): headers to send with request (cookies, user-agent, etc).
- `waitFor` (integer, default `0`): delay in milliseconds before fetching content.
- `mobile` (boolean, default `false`): emulate scraping from mobile device.
- `skipTlsVerification` (boolean, default `true`): skip TLS certificate verification.
- `timeout` (integer, default `30000`, max `300000`): timeout for request in milliseconds.
- `parsers` (array): controls how files are processed (e.g., PDF with `maxPages`).
- `actions` (array): actions to perform on page before grabbing content (`wait`, `click`, `write`, `press`, `screenshot`, `scrape`, `scroll`, `executeJavascript`, `pdf`).
- `location` (object): geographic settings with `country` (ISO 3166-1 alpha-2) and `languages`.
- `removeBase64Images` (boolean, default `true`): removes base64 images from output.
- `blockAds` (boolean, default `true`): enables ad-blocking and cookie popup blocking.
- `proxy` (`basic` | `stealth` | `auto`, default `auto`): type of proxy for scraping.
- `storeInCache` (boolean, default `true`): if true, page stored in Firecrawl index and cache.

### Data retention
- `zeroDataRetention` (boolean, default `false`): enables zero data retention for this batch.

## Response

On success you receive a job object (including an `id`). Use the status endpoint to retrieve results.

## Errors

- `402` payment required
- `429` rate limit exceeded
- `500` server error
