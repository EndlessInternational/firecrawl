# Get Crawl Errors (v2)

Returns error details for pages that failed within a crawl job.

## HTTP request

- **Method:** `GET`
- **Path:** `/v2/crawl/{id}/errors`
- **Auth:** `Authorization: Bearer <API_KEY>`

## Path params
- `id` (uuid): crawl job id

## Response

Returns:

- `errors`: array of failed items (`id`, `timestamp`, `url`, `error`)
- `robotsBlocked`: list of URLs blocked by `robots.txt`

## Errors
- `402` payment required
- `429` rate limit exceeded
- `500` server error
