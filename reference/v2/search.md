# Search (v2)

Search runs a web search query and returns results. You can optionally attach `scrapeOptions` so Firecrawl also scrapes each result and returns content (e.g., Markdown).

## HTTP request

- **Method:** `POST`
- **Path:** `/v2/search`
- **Auth:** `Authorization: Bearer <API_KEY>`

## Request body

### Required
- `query` (string): the search query.

### Common optional fields
- `limit` (integer): max results to return.
- `country` (string, ISO): geo-target results (default is typically US).
- `location` (string): location name like `"Germany"` or `"San Francisco,California,United States"`.
- `categories` (string[]): restrict sources (e.g. `github`, `research`, `pdf`).
- `tbs` / time filters (if provided by the API): limit by recency.
- `scrapeOptions` (object): if set, Firecrawl scrapes the result pages.
  - Example: `formats: [{"type":"markdown"}]` to include markdown content per result.

## Response

Returns a success indicator and a results payload (commonly includes `url`, `title`, `description`, and when `scrapeOptions` are provided, scraped fields like `markdown`).

## Errors
- `402` payment required
- `429` rate limit exceeded
- `500` server error
