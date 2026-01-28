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
- `url` (string, URL): the base URL to start crawling from.

### Crawl scope
- `prompt` (string): natural language prompt to generate crawl options (explicit fields override).
- `includePaths` / `excludePaths` (string[]): URL pathname regex patterns to include/exclude.
- `maxDiscoveryDepth` (integer): maximum depth to crawl based on discovery order.
- `sitemap` (`include` | `skip` | `only`, default `include`): sitemap mode when crawling.
- `ignoreQueryParameters` (boolean, default `false`): do not re-scrape the same path with different query parameters.
- `limit` (integer, default `10000`): maximum number of pages to crawl.

### Domain and link following
- `crawlEntireDomain` (boolean, default `false`): allows the crawler to follow internal links to siblings or parents.
- `allowExternalLinks` (boolean, default `false`): allows the crawler to follow links to external websites.
- `allowSubdomains` (boolean, default `false`): allows the crawler to follow links to subdomains of the main domain.

### Rate limiting
- `delay` (number): delay in seconds between scrapes.
- `maxConcurrency` (integer): maximum number of concurrent scrapes.

### Webhook
- `webhook` (object): receive events as the job runs.
  - `url` (string, required): the URL to send webhook events to.
  - `headers` (object): custom headers to send with webhook requests.
  - `metadata` (object): custom metadata included in webhook payloads.
  - `events` (string[]): which events to send (`started`, `page`, `completed`, `failed`).

### Scraping controls
- `scrapeOptions` (object): controls formats (markdown/html/etc), actions, proxy, headers, etc. (same model as `/scrape`).

### Data retention
- `zeroDataRetention` (boolean, default `false`): enables zero data retention for this crawl.

## Response

Returns a job object (includes `id`). Use `GET /v2/crawl/{id}` to retrieve results.

## Errors
- `402` payment required
- `429` rate limit exceeded
- `500` server error
