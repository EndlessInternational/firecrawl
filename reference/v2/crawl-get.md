# Get Crawl Status (v2)

Retrieves the status of a crawl job and (when available) the scraped results.

## HTTP request

- **Method:** `GET`
- **Path:** `/v2/crawl/{id}`
- **Auth:** `Authorization: Bearer <API_KEY>`

## Path params
- `id` (uuid): crawl job id returned by `POST /v2/crawl`

## Response

Key fields:

- `status`: `scraping` | `completed` | `failed`
- `total`, `completed`
- `creditsUsed`
- `expiresAt`
- `next` (string|null): pagination/chunk URL for large results
- `data`: array of per-page results (fields depend on your `scrapeOptions.formats`)

## Errors
- `402` payment required
- `429` rate limit exceeded
- `500` server error
