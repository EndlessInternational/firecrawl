# Map (v2)

Map discovers URLs for a site quickly and returns a list of links (with optional title/description when available). It is focused on **URL discovery**, not full scraping of every page.

## HTTP request

- **Method:** `POST`
- **Path:** `/v2/map`
- **Auth:** `Authorization: Bearer <API_KEY>`

## Request body

### Required
- `url` (string, URL): the base URL to start crawling from.

### URL discovery
- `search` (string): specify a search query to order the results by relevance. Example: 'blog' will return URLs that contain the word 'blog'.
- `limit` (integer, default `5000`, max `100000`): maximum number of links to return.

### Sitemap handling
- `sitemap` (`include` | `skip` | `only`, default `include`): controls sitemap usage. `skip` ignores it, `only` uses sitemap URLs, `include` combines sitemap with other discovery methods.
- `ignoreCache` (boolean, default `false`): bypass the sitemap cache to retrieve fresh URLs. Sitemap data is cached for up to 7 days.

### Filtering
- `includeSubdomains` (boolean, default `true`): include subdomains of the website.
- `ignoreQueryParameters` (boolean, default `true`): do not return URLs with query parameters.

### Request settings
- `timeout` (integer): timeout in milliseconds. There is no timeout by default.
- `location` (object): geographic settings for the request.
  - `country` (string, default `US`): ISO 3166-1 alpha-2 country code (e.g., 'US', 'AU', 'DE', 'JP').
  - `languages` (array): preferred languages and locales for the request in order of priority.

## Response

Returns:
- `success` (boolean)
- `links`: array of `{ url, title?, description? }`

## Errors
- `402` payment required
- `429` rate limit exceeded
- `500` server error
