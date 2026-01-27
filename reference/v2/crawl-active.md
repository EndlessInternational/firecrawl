# Get Active Crawls (v2)

Lists crawl jobs that are currently active for the authenticated team.

## HTTP request

- **Method:** `GET`
- **Path:** `/v2/crawl/active`
- **Auth:** `Authorization: Bearer <API_KEY>`

## Response

Returns:

- `success` (boolean)
- `crawls` (array): each crawl typically includes:
  - `id`
  - `teamId`
  - `url`
  - `status`
  - `options` (including `scrapeOptions`)

## Errors
- `402` payment required
- `429` rate limit exceeded
- `500` server error
