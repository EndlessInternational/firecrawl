# Firecrawl

The **Firecrawl** gem provides a Ruby interface to the [Firecrawl API](https://firecrawl.dev), enabling you to scrape web pages, capture screenshots, and crawl entire websites. The API returns clean, structured content in formats like Markdown and HTML, making it particularly useful for applications that need to process web content, including those using Large Language Models for grounding or real-time information retrieval.

```ruby
require 'firecrawl'

Firecrawl.api_key ENV[ 'FIRECRAWL_API_KEY' ]

response = Firecrawl.scrape( 'https://example.com' )
if response.success?
  result = response.result
  puts result.metadata[ 'title' ]
  puts result.markdown
end
```

---

## Table of Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [Endpoints](#endpoints)
  - [Scrape](#scrape)
  - [Batch Scrape](#batch-scrape)
  - [Map](#map)
  - [Crawl](#crawl)
- [Responses and Errors](#responses-and-errors)
- [Connections](#connections)
- [License](#license)

---

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'firecrawl'
```

Then execute:

```bash
bundle install
```

Or install it directly:

```bash
gem install firecrawl
```

## Quick Start

The simplest way to use the gem is through the module-level convenience methods. Set your API key once, then call any endpoint:

```ruby
require 'firecrawl'

Firecrawl.api_key ENV[ 'FIRECRAWL_API_KEY' ]

response = Firecrawl.scrape( 'https://example.com' )
if response.success?
  puts response.result.markdown
end
```

For more control, instantiate request objects directly. This allows you to configure options using a block-based DSL and reuse request instances:

```ruby
request = Firecrawl::ScrapeRequest.new( api_key: ENV[ 'FIRECRAWL_API_KEY' ] )

options = Firecrawl::ScrapeOptions.build do
  formats [ :markdown, :html, :screenshot ]
  only_main_content true
end

response = request.submit( 'https://example.com', options )
```

---

## Endpoints

### Scrape

The scrape endpoint fetches a single URL and returns the page content in one or more formats. You can optionally run browser actions before content is captured.

```ruby
options = Firecrawl::ScrapeOptions.build do
  formats [ :markdown, :screenshot ]
  only_main_content true
  screenshot do
    full_page true
  end
end

request = Firecrawl::ScrapeRequest.new( api_key: ENV[ 'FIRECRAWL_API_KEY' ] )
response = request.submit( 'https://example.com', options )

if response.success?
  result = response.result
  puts result.markdown
  puts result.screenshot_url
end
```

For complete documentation of all scrape options and response fields, see [Scrape Documentation](readme/scrape.md).

### Batch Scrape

The batch scrape endpoint processes multiple URLs efficiently. It returns results asynchronously, so you poll for completion:

```ruby
request = Firecrawl::BatchScrapeRequest.new( api_key: ENV[ 'FIRECRAWL_API_KEY' ] )

urls = [ 'https://example.com', 'https://example.org' ]
options = Firecrawl::ScrapeOptions.build do
  formats [ :markdown ]
  only_main_content true
end

response = request.submit( urls, options )

while response.success?
  batch_result = response.result
  batch_result.each do | scrape_result |
    puts scrape_result.markdown
  end
  break unless batch_result.scraping?
  sleep 1
  response = request.retrieve( batch_result )
end
```

For complete documentation of all batch scrape options and response fields, see [Batch Scrape Documentation](readme/batch_scrape.md).

### Map

The map endpoint retrieves a site's URL structure without scraping content. This is useful for discovering pages before scraping:

```ruby
request = Firecrawl::MapRequest.new( api_key: ENV[ 'FIRECRAWL_API_KEY' ] )

options = Firecrawl::MapOptions.build do
  limit 100
  include_subdomains false
end

response = request.submit( 'https://example.com', options )

if response.success?
  response.result.links.each do | link |
    puts link
  end
end
```

### Crawl

The crawl endpoint recursively scrapes an entire website. Like batch scrape, it returns results asynchronously:

```ruby
request = Firecrawl::CrawlRequest.new( api_key: ENV[ 'FIRECRAWL_API_KEY' ] )

options = Firecrawl::CrawlOptions.build do
  maximum_depth 2
  limit 50
  scrape_options do
    formats [ :markdown ]
    only_main_content true
  end
end

response = request.submit( 'https://example.com', options )

while response.success?
  crawl_result = response.result
  crawl_result.each do | scrape_result |
    puts scrape_result.metadata[ 'title' ]
  end
  break unless crawl_result.scraping?
  sleep 1
  response = request.retrieve( crawl_result )
end
```

---

## Responses and Errors

All request methods return a `Faraday::Response` object. Check `response.success?` to determine if the HTTP request succeeded. When successful, `response.result` contains the parsed result object specific to the endpoint.

```ruby
response = request.submit( url, options )

if response.success?
  result = response.result
  if result.success?
    # process result
  end
else
  error = response.result
  puts error.error_type         # :authentication_error, :rate_limit_error, etc.
  puts error.error_description  # human-readable message
end
```

The gem maps HTTP status codes to error types:

| Status | Error Type | Description |
|--------|------------|-------------|
| 400 | `:invalid_request_error` | The request format or content was invalid |
| 401 | `:authentication_error` | The API key is missing or invalid |
| 402 | `:payment_required` | The account requires payment |
| 404 | `:not_found_error` | The requested resource was not found |
| 429 | `:rate_limit_error` | The account has exceeded rate limits |
| 500-505 | `:api_error` | A server error occurred |
| 529 | `:overloaded_error` | The service is temporarily overloaded |

---

## Connections

The gem uses Faraday for HTTP requests, which means you can customize the connection configuration. To use a custom connection:

```ruby
connection = Faraday.new do | faraday |
  faraday.request :json
  faraday.response :logger
  faraday.adapter :net_http
end

Firecrawl.connection connection
```

Or pass it directly to a request:

```ruby
request = Firecrawl::ScrapeRequest.new(
  api_key: ENV[ 'FIRECRAWL_API_KEY' ],
  connection: connection
)
```

---

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
