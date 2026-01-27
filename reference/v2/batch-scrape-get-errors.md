# Get Batch Scrape Errors (v2)

Returns error details for URLs that failed inside a batch scrape job.

## HTTP request

- **Method:** `GET`
- **Path:** `/v2/batch/scrape/{id}/errors`
- **Auth:** `Authorization: Bearer <API_KEY>`

## Path params
- `id` (uuid): batch scrape job id

## Response

Returns an object containing:

- `errors`: array of failed items (`id`, `timestamp`, `url`, `error`)
- `robotsBlocked`: list of URLs blocked by `robots.txt`

## Errors
- `402` payment required
- `429` rate limit exceeded
- `500` server error
