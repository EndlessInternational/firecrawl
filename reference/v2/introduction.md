# Firecrawl API (v2) — Introduction

This section explains the basics you need before calling any v2 endpoint: what Firecrawl can do, what base URL to use, how authentication works, and what common HTTP responses mean.

## What you can do with v2

Firecrawl’s v2 API groups endpoints into a few core capabilities:

- **Scrape**: Fetch a single URL and return its content (typically as Markdown or JSON).
- **Batch Scrape**: Scrape many URLs in one job and poll for results.
- **Crawl**: Discover and scrape many pages starting from a base URL (site crawling) and poll for results.
- **Map**: Quickly return a list of URLs found for a site (URL discovery without scraping every page).
- **Search**: Run a web search query and optionally return scraped content for the results.

(There are also "agentic" endpoints like **Extract**, which turn page content into structured data from natural-language instructions.)

## Base URL

All requests go to the Firecrawl API host:

```
https://api.firecrawl.dev
```

Most v2 endpoints are exposed under the `/v2` path (for example: `https://api.firecrawl.dev/v2/scrape`). The per-endpoint pages show the exact path.

## Authentication

Every request must include an `Authorization` header using a Bearer token:

```
Authorization: Bearer <YOUR_API_KEY>
```

Example:

```
Authorization: Bearer fc-123456789
```

## Common response codes

Firecrawl uses standard HTTP response codes:

- **200** — Success.
- **400** — Invalid request (check your JSON body/parameters).
- **401** — Missing or invalid API key.
- **402** — Payment required (plan/billing issue).
- **404** — Endpoint or resource not found.
- **429** — Rate limit exceeded (slow down and retry later).
- **5xx** — Firecrawl server error.

## Rate limits

Requests are rate-limited across endpoints to protect service stability.

If you exceed the limit you’ll receive **HTTP 429**.
