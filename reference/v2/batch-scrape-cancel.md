# Cancel Batch Scrape (v2)

Cancels an in-progress batch scrape job.

## HTTP request

- **Method:** `DELETE`
- **Path:** `/v2/batch/scrape/{id}`
- **Auth:** `Authorization: Bearer <API_KEY>`

## Path params
- `id` (uuid): batch scrape job id

## Response

Returns a success indicator (and may return the final job state depending on the backend).

## Errors
- `402` payment required
- `429` rate limit exceeded
- `500` server error
