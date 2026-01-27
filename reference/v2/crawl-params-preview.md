# Crawl Params Preview (v2)

Generates/returns crawl parameters from a natural-language prompt **without starting a crawl**. Useful for debugging what the crawler *would* do.

## HTTP request

- **Method:** `POST`
- **Path:** `/v2/crawl/params-preview`
- **Auth:** `Authorization: Bearer <API_KEY>`

## Request body

Required:
- `url` (string, URL): the target site/page
- `prompt` (string): natural-language instructions (max length per docs)

## Response

Returns `success: true` and a `data` object containing generated crawl options such as:
- `includePaths`, `excludePaths`
- depth limits
- sitemap strategy
- query param dedupe
- delays
- limits

## Errors
- `400` bad request (invalid input)
- `402` payment required
- `429` rate limit exceeded
- `500` server error
