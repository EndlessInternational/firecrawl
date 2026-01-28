# Crawl

The crawl endpoint recursively discovers and scrapes pages starting from a base URL. It creates an asynchronous job that you poll for results.

## Basic Usage

```ruby
request = Firecrawl::CrawlRequest.new( api_key: ENV[ 'FIRECRAWL_API_KEY' ] )
response = request.submit( 'https://example.com' )

while response.success?
  result = response.result
  result.each do | scrape_result |
    puts scrape_result.metadata[ 'title' ]
    puts scrape_result.markdown
  end
  break unless result.crawling?
  sleep 2
  response = request.retrieve( result )
end
```

## Options

Options can be passed as a hash or built using the DSL:

```ruby
# using DSL
options = Firecrawl::CrawlOptions.build do
  limit 100
  maximum_depth 2
  scrape_options do
    formats [ :markdown ]
    only_main_content true
  end
end

# using hash
options = {
  limit: 100,
  maximum_depth: 2,
  scrape_options: { formats: [ :markdown ] }
}

response = request.submit( url, options )
```

---

## Crawl Scope

### Limit

Control the maximum number of pages to crawl:

```ruby
options = Firecrawl::CrawlOptions.build do
  limit 50
end
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `limit` | integer | 10000 | Maximum number of pages to scrape |

### Discovery Depth

Limit how deep the crawler follows links:

```ruby
options = Firecrawl::CrawlOptions.build do
  maximum_depth 2
end
```

| Option | Type | Description |
|--------|------|-------------|
| `maximum_depth` | integer | Maximum link depth from the starting URL |

### Natural Language Prompt

Use a natural language prompt to guide the crawl (explicit options override):

```ruby
options = Firecrawl::CrawlOptions.build do
  prompt 'Find all documentation pages'
end
```

---

## Path Filtering

Control which paths are included or excluded using regex patterns:

```ruby
options = Firecrawl::CrawlOptions.build do
  include_paths [ '/docs/.*', '/api/.*' ]
  exclude_paths [ '/admin/.*', '/internal/.*' ]
end
```

| Option | Type | Description |
|--------|------|-------------|
| `include_paths` | array | Regex patterns for paths to include |
| `exclude_paths` | array | Regex patterns for paths to exclude |

---

## Sitemap Handling

Control how the site's sitemap is used:

```ruby
options = Firecrawl::CrawlOptions.build do
  sitemap :include
end
```

| Mode | Description |
|------|-------------|
| `:include` | Use sitemap in addition to link discovery (default) |
| `:skip` | Ignore the sitemap, use link discovery only |
| `:only` | Use only the sitemap, skip link discovery |

---

## Subdomain and External Links

```ruby
options = Firecrawl::CrawlOptions.build do
  crawl_entire_domain true
  allow_subdomains true
  allow_external_links false
  ignore_query_parameters true
end
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `crawl_entire_domain` | boolean | false | Follow internal links to siblings or parents |
| `allow_subdomains` | boolean | false | Include pages from subdomains |
| `allow_external_links` | boolean | false | Follow links to external domains |
| `ignore_query_parameters` | boolean | false | Treat URLs with different query params as duplicates |

---

## Rate Limiting

Control the crawl speed:

```ruby
options = Firecrawl::CrawlOptions.build do
  delay 1000
  max_concurrency 5
end
```

| Option | Type | Description |
|--------|------|-------------|
| `delay` | integer | Delay between requests in milliseconds |
| `max_concurrency` | integer | Maximum concurrent requests |

---

## Scrape Options

Configure how each page is scraped. All options from [scrape](scrape.md) are available:

```ruby
options = Firecrawl::CrawlOptions.build do
  limit 50
  scrape_options do
    formats [ :markdown, :html ]
    only_main_content true
    screenshot do
      full_page true
    end
  end
end
```

---

## Data Retention

```ruby
options = Firecrawl::CrawlOptions.build do
  zero_data_retention true
end
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `zero_data_retention` | boolean | false | Enables zero data retention for this crawl |

---

## Webhooks

Receive notifications about crawl progress:

```ruby
options = Firecrawl::CrawlOptions.build do
  limit 100
  webhook do
    url 'https://your-server.com/webhook'
    headers( { 'Authorization' => 'Bearer your-token' } )
    metadata( { crawl_id: 'my-crawl-123' } )
    events [ :started, :page, :completed, :failed ]
  end
end
```

| Option | Type | Description |
|--------|------|-------------|
| `url` | string | The webhook URL to receive notifications |
| `headers` | hash | Custom headers to send with webhook requests |
| `metadata` | hash | Custom metadata included in webhook payloads |
| `events` | array | Which events to receive |

### Webhook Events

| Event | Description |
|-------|-------------|
| `:started` | Fired when the crawl job starts |
| `:page` | Fired when each page is scraped |
| `:completed` | Fired when the crawl finishes |
| `:failed` | Fired if the crawl job fails |

---

## Polling for Results

After submitting a crawl, poll for results using `retrieve`:

```ruby
response = request.submit( url, options )

while response.success?
  result = response.result

  # process newly completed results
  result.each do | scrape_result |
    puts "#{ scrape_result.metadata[ 'title' ] }"
    puts scrape_result.markdown
  end

  # check progress
  puts "Progress: #{ result.completed } / #{ result.total }"

  # check if still crawling
  break unless result.crawling?

  # wait before polling again
  sleep 2
  response = request.retrieve( result )
end

puts "Credits used: #{ result.credits_used }"
```

---

## Cancelling a Crawl

Cancel an in-progress crawl:

```ruby
response = request.submit( url, options )
result = response.result

# later, cancel the crawl
cancel_response = request.cancel( result )

if cancel_response.success?
  puts "Crawl cancelled"
end
```

---

## Response

When the request succeeds, `response.result` is a `CrawlResult` object.

### Job Status

| Accessor | Type | Description |
|----------|------|-------------|
| `id` | string | The crawl job ID |
| `status` | symbol | Current status: `:scraping`, `:completed`, `:failed`, or `:cancelled` |
| `url` | string | URL to retrieve results |
| `total` | integer | Total number of pages to scrape |
| `completed` | integer | Number of pages completed |
| `credits_used` | integer | Number of credits consumed |
| `expires_at` | string | When the stored results expire |

### Status Helpers

```ruby
result = response.result

result.success?     # true if the API call succeeded
result.crawling?    # true if status is :scraping
result.completed?   # true if status is :completed
result.failed?      # true if status is :failed
result.cancelled?   # true if status is :cancelled
result.status?( :scraping )  # check for specific status
```

### Scrape Results

The `data` array contains `ScrapeResultData` objects for each crawled page. You can iterate directly:

```ruby
result.each do | scrape_result |
  puts scrape_result.metadata[ 'title' ]
  puts scrape_result.markdown
  puts scrape_result.html
end

# or access by index
first_result = result[ 0 ]

# array methods
result.length   # number of results
result.empty?   # true if no results yet
```

Each scrape result has the same accessors as a regular scrape response. See [Scrape Response](scrape.md#response) for details.
