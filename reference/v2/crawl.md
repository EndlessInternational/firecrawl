# Crawl (v2)

Crawl creates an **asynchronous crawl job** starting from a base URL. Firecrawl discovers pages (via sitemap and/or link discovery depending on settings) and scrapes them using `scrapeOptions`.

## HTTP request

- **Method:** `POST`
- **Path:** `/v2/crawl`
- **Auth:** `Authorization: Bearer <API_KEY>`

## Typical workflow

1. Start a crawl: `POST /v2/crawl`
2. Poll status/results: `GET /v2/crawl/{id}`
3. Fetch failures: `GET /v2/crawl/{id}/errors`
4. Cancel if needed: `DELETE /v2/crawl/{id}`

## Request body

### Required
- `url` (string, URL): the origin to crawl.

### Common crawl controls (high level)
- `prompt` (string): natural language prompt to generate crawl options (explicit fields override).
- `includePaths` / `excludePaths` (string[]): regex patterns against the URL pathname.
- `maxDiscoveryDepth` (integer): discovery depth limit.
- `sitemap` (`include` | `skip` | `only`, default `include`).
- `ignoreQueryParameters` (boolean): avoid re-scraping same path with different query params.
- `limit` (integer, default ~10000): max pages.

### Scraping controls
- `scrapeOptions` (object): controls formats (markdown/html/etc), actions, proxy, headers, etc. (same model as `/scrape`).

## Response

Returns a job object (includes `id`). Use `GET /v2/crawl/{id}` to retrieve results.

## Errors
- `402` payment required
- `429` rate limit exceeded
- `500` server error
