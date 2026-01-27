# Get Batch Scrape Status (v2)

Fetches the current state of a batch scrape job and (when available) the scraped results.

## HTTP request

- **Method:** `GET`
- **Path:** `/v2/batch/scrape/{id}`
- **Auth:** `Authorization: Bearer <API_KEY>`

## Path params
- `id` (uuid): batch scrape job id returned by `POST /v2/batch/scrape`

## Response

Returns an object with (key fields):

- `status`: `scraping` | `completed` | `failed`
- `total`: total URLs attempted
- `completed`: number successfully scraped
- `creditsUsed`
- `expiresAt`: when the stored results expire
- `next` (string|null): URL to fetch the next chunk if results are large
- `data`: array of per-page results (fields depend on requested formats; commonly includes `markdown`, optional `html`, `rawHtml`, `links`, `screenshot`, `metadata`, etc.)

## Errors
- `402` payment required
- `429` rate limit exceeded
- `500` server error
