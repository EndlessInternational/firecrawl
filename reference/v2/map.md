# Map (v2)

Map discovers URLs for a site quickly and returns a list of links (with optional title/description when available). It is focused on **URL discovery**, not full scraping of every page.

## HTTP request

- **Method:** `POST`
- **Path:** `/v2/map`
- **Auth:** `Authorization: Bearer <API_KEY>`

## Request body

### Required
- `url` (string, URL): the base URL to start from.

### Optional
- `search` (string): order returned URLs by relevance to this keyword (matches in URL).
- `sitemap` (`include` | `skip` | `only`, default `include`): how to use the sitemap.
- `includeSubdomains` (boolean, default `true`)
- `ignoreQueryParameters` (boolean, default `true`)
- `ignoreCache` (boolean, default `false`): bypass cached sitemap (cache up to ~7 days per docs)
- `limit` (integer, default `5000`, max `100000`)
- `timeout` (ms): request timeout
- `location` (object): proxy/locale hints (`country`, `languages`)

## Response

Returns:
- `success` (boolean)
- `links`: array of `{ url, title?, description? }`

## Errors
- `402` payment required
- `429` rate limit exceeded
- `500` server error
