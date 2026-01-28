# Batch Scrape

The batch scrape endpoint processes multiple URLs efficiently in a single asynchronous job. It returns results as they complete, so you poll for completion.

## Basic Usage

```ruby
request = Firecrawl::BatchScrapeRequest.new( api_key: ENV[ 'FIRECRAWL_API_KEY' ] )

urls = [ 'https://example.com', 'https://example.org' ]
response = request.submit( urls )

while response.success?
  result = response.result
  result.each do | scrape_result |
    puts scrape_result.markdown
  end
  break unless result.scraping?
  sleep 1
  response = request.retrieve( result )
end
```

## Options

Options can be passed as a hash or built using the DSL. Batch scrape accepts all the same options as [scrape](scrape.md), plus batch-specific configuration:

```ruby
# using DSL
options = Firecrawl::BatchScrapeOptions.build do
  formats [ :markdown, :html ]
  only_main_content true
  max_concurrency 5
  ignore_invalid_urls true
  webhook do
    url 'https://your-server.com/webhook'
    events [ :completed, :page ]
  end
end

# using hash
options = { formats: [ :markdown ], only_main_content: true }

response = request.submit( urls, options )
```

---

## Batch-Specific Options

These options are unique to batch scrape:

```ruby
options = Firecrawl::BatchScrapeOptions.build do
  max_concurrency 10
  ignore_invalid_urls true
end
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `max_concurrency` | integer | team limit | Maximum parallel scrapes for this batch |
| `ignore_invalid_urls` | boolean | true | Ignore invalid URLs instead of failing the whole request |

---

## Output Formats

Batch scrape supports the same formats as the scrape endpoint. See [Scrape Output Formats](scrape.md#output-formats) for the complete list.

```ruby
options = Firecrawl::BatchScrapeOptions.build do
  formats [ :markdown, :html, :screenshot ]
end
```

---

## Content Filtering

These options control which content is included in each scraped result.

```ruby
options = Firecrawl::BatchScrapeOptions.build do
  only_main_content true
  include_tags [ 'article', 'main' ]
  exclude_tags [ 'nav', 'footer', 'aside' ]
  remove_base64_images true
  block_ads true
end
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `only_main_content` | boolean | true | Return only main content, excluding navigation |
| `include_tags` | array | none | Only include content from these HTML tags |
| `exclude_tags` | array | none | Exclude content from these HTML tags |
| `remove_base64_images` | boolean | true | Replace base64 images with placeholders |
| `block_ads` | boolean | true | Enable ad blocking and cookie popup blocking |

---

## Timing and Caching

```ruby
options = Firecrawl::BatchScrapeOptions.build do
  wait_for 2000
  timeout 60000
  max_age 86400000
  cache true
end
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `wait_for` | integer | 0 | Additional delay in milliseconds before capturing content |
| `timeout` | integer | 30000 | Request timeout in milliseconds (max 300000) |
| `max_age` | integer | 172800000 | Allow cached responses if newer than this value in milliseconds |
| `cache` | boolean | true | Whether to store pages in Firecrawl's cache |

---

## Network and Browser

```ruby
options = Firecrawl::BatchScrapeOptions.build do
  mobile true
  skip_tls_verification true
  proxy :stealth
  headers( { 'Cookie' => 'session=abc123' } )
  location 'US' do
    languages [ 'en-US', 'en' ]
  end
end
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `mobile` | boolean | false | Emulate a mobile device |
| `skip_tls_verification` | boolean | true | Skip TLS certificate verification |
| `proxy` | symbol | `:auto` | Proxy mode: `:basic`, `:stealth`, or `:auto` |
| `headers` | hash | none | Custom HTTP headers to send with requests |
| `location` | object | none | Location settings with `country` and `languages` |

---

## Webhooks

Batch scrape supports webhooks to notify your server of progress and completion:

```ruby
options = Firecrawl::BatchScrapeOptions.build do
  formats [ :markdown ]
  webhook do
    url 'https://your-server.com/firecrawl-webhook'
    headers( { 'Authorization' => 'Bearer your-token' } )
    metadata( { batch_id: 'my-batch-123' } )
    events [ :started, :page, :completed, :failed ]
  end
end
```

| Option | Type | Description |
|--------|------|-------------|
| `url` | string | The webhook URL to receive notifications |
| `headers` | hash | Custom headers to send with webhook requests |
| `metadata` | hash | Custom metadata included in webhook payloads |
| `events` | array | Which events to receive: `:started`, `:page`, `:completed`, `:failed` |

### Webhook Events

| Event | Description |
|-------|-------------|
| `:started` | Fired when the batch scrape job starts |
| `:page` | Fired when each individual page is scraped |
| `:completed` | Fired when all URLs have been processed |
| `:failed` | Fired if the batch scrape job fails |

---

## Polling for Results

After submitting a batch scrape, you need to poll for results. The `retrieve` method returns incremental results since your last call:

```ruby
response = request.submit( urls, options )

while response.success?
  result = response.result

  # process newly completed results
  result.each do | scrape_result |
    puts "#{ scrape_result.metadata[ 'title' ] }: #{ scrape_result.markdown&.length } chars"
  end

  # check if still scraping
  break unless result.scraping?

  # wait before polling again
  sleep 2
  response = request.retrieve( result )
end

puts "Total completed: #{ result.completed } / #{ result.total }"
puts "Credits used: #{ result.credits_used }"
```

### Retrieve All

Use `retrieve_all` to get all results accumulated so far (including previously returned results):

```ruby
response = request.retrieve_all( result )
```

---

## Response

When the request succeeds, `response.result` is a `BatchScrapeResult` object.

### Job Status

| Accessor | Type | Description |
|----------|------|-------------|
| `id` | string | The batch scrape job ID |
| `status` | symbol | Current status: `:scraping`, `:completed`, `:failed`, or `:cancelled` |
| `url` | string | URL to retrieve results |
| `total` | integer | Total number of URLs to scrape |
| `completed` | integer | Number of URLs completed |
| `credits_used` | integer | Number of credits consumed |
| `expires_at` | string | When the stored results expire |
| `invalid_urls` | array | List of URLs that could not be scraped |

### Status Helpers

```ruby
result = response.result

result.success?     # true if the API call succeeded
result.scraping?    # true if status is :scraping
result.completed?   # true if status is :completed
result.failed?      # true if status is :failed
result.cancelled?   # true if status is :cancelled
result.status?( :scraping )  # check for specific status
```

### Scrape Results

The `data` array contains `ScrapeResultData` objects for each completed URL. You can iterate over them directly:

```ruby
result.each do | scrape_result |
  puts scrape_result.metadata[ 'title' ]
  puts scrape_result.markdown
  puts scrape_result.html
  puts scrape_result.screenshot_url
end

# or access by index
first_result = result[ 0 ]

# array methods
result.length   # number of results
result.empty?   # true if no results yet
```

Each scrape result has the same accessors as a regular scrape response. See [Scrape Response](scrape.md#response) for details.
