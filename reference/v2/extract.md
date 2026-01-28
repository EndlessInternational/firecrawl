# Extract (v2)

Extract uses LLM to pull structured data from one or more URLs. You provide URLs (optionally with glob patterns), a prompt and/or JSON schema, and Firecrawl returns structured data matching your requirements.

## HTTP request

- **Method:** `POST`
- **Path:** `/v2/extract`
- **Auth:** `Authorization: Bearer <API_KEY>`

## Typical workflow

1. Start extraction: `POST /v2/extract`
2. Poll status/results: `GET /v2/extract/{id}`

## Request body

### Required
- `urls` (string[]): the URLs to extract data from. URLs can be in glob format (e.g., `https://example.com/blog/*`).

### Extraction options
- `prompt` (string): guidance text to direct the extraction process.
- `schema` (object): JSON Schema defining the structure of the extracted data.
- `enableWebSearch` (boolean, default `false`): when true, use web search to find additional data.
- `showSources` (boolean, default `false`): when true, include the sources used to extract the data in the response.

### URL handling
- `ignoreSitemap` (boolean, default `false`): when true, sitemap.xml files will be ignored during website scanning.
- `includeSubdomains` (boolean, default `true`): when true, subdomains of the provided URLs will also be scanned.
- `ignoreInvalidURLs` (boolean, default `true`): invalid URLs are ignored; valid ones are processed and invalid ones returned separately.

### Scrape options
- `scrapeOptions` (object): controls how pages are scraped before extraction.
  - `formats` (array, default `[markdown]`): output formats.
  - `onlyMainContent` (boolean, default `true`): only return main content.
  - `includeTags` / `excludeTags` (string[]): tags to include/exclude.
  - `maxAge` (integer, default `172800000`): cache age in milliseconds.
  - `headers` (object): custom request headers.
  - `waitFor` (integer, default `0`): delay before fetching.
  - `mobile` (boolean, default `false`): emulate mobile device.
  - `skipTlsVerification` (boolean, default `true`): skip TLS verification.
  - `timeout` (integer, default `30000`, max `300000`): request timeout.
  - `parsers` (array): file processing options.
  - `actions` (array): browser actions before scraping.
  - `location` (object): geographic settings (`country`, `languages`).
  - `removeBase64Images` (boolean, default `true`): remove base64 images.
  - `blockAds` (boolean, default `true`): enable ad blocking.
  - `proxy` (`basic` | `stealth` | `auto`, default `auto`): proxy type.
  - `storeInCache` (boolean, default `true`): cache the page.

## Response

Returns a job object (includes `id`). Use `GET /v2/extract/{id}` to retrieve results.

## Errors
- `402` payment required
- `429` rate limit exceeded
- `500` server error
