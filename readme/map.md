# Map

The map endpoint discovers URLs for a site quickly and returns a list of links with optional titles and descriptions. It focuses on URL discovery without scraping the content of every page.

## Basic Usage

```ruby
request = Firecrawl::MapRequest.new( api_key: ENV[ 'FIRECRAWL_API_KEY' ] )
response = request.submit( 'https://example.com' )

if response.success?
  result = response.result
  result.each do | link |
    puts link.url
    puts link.title
    puts link.description
  end
end
```

## Options

Options can be passed as a hash or built using the DSL:

```ruby
# using DSL
options = Firecrawl::MapOptions.build do
  limit 100
  include_subdomains false
  search 'blog'
end

# using hash
options = { limit: 100, include_subdomains: false }

response = request.submit( url, options )
```

---

## URL Discovery

### Search

Order returned URLs by relevance to a keyword:

```ruby
options = Firecrawl::MapOptions.build do
  search 'documentation'
end
```

URLs containing or related to the search term will be ranked higher in the results.

### Limit

Control the maximum number of URLs returned:

```ruby
options = Firecrawl::MapOptions.build do
  limit 500
end
```

| Option | Type | Default | Max | Description |
|--------|------|---------|-----|-------------|
| `limit` | integer | 5000 | 100000 | Maximum number of URLs to return |

---

## Sitemap Handling

Control how the site's sitemap is used for URL discovery:

```ruby
options = Firecrawl::MapOptions.build do
  sitemap :include
end
```

| Mode | Description |
|------|-------------|
| `:include` | Use sitemap in addition to link discovery (default) |
| `:skip` | Ignore the sitemap, use link discovery only |
| `:only` | Use only the sitemap, skip link discovery |

---

## Subdomain and Query Parameters

```ruby
options = Firecrawl::MapOptions.build do
  include_subdomains true
  ignore_query_parameters true
end
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `include_subdomains` | boolean | true | Include URLs from subdomains |
| `ignore_query_parameters` | boolean | true | Treat URLs with different query params as duplicates |

---

## Caching

```ruby
options = Firecrawl::MapOptions.build do
  ignore_cache true
end
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `ignore_cache` | boolean | false | Bypass cached sitemap data (cache is ~7 days) |

---

## Timing

```ruby
options = Firecrawl::MapOptions.build do
  timeout 60000
end
```

| Option | Type | Description |
|--------|------|-------------|
| `timeout` | integer | Request timeout in milliseconds |

---

## Location

Specify location for proxy and locale settings:

```ruby
options = Firecrawl::MapOptions.build do
  location 'US' do
    languages [ 'en-US', 'en' ]
  end
end
```

| Option | Type | Description |
|--------|------|-------------|
| `country` | string | ISO 3166-1 alpha-2 country code (e.g., 'US', 'DE', 'JP') |
| `languages` | array | Preferred languages in Accept-Language format |

---

## Response

When the request succeeds, `response.result` is a `MapResult` object.

### Result Accessors

| Accessor | Type | Description |
|----------|------|-------------|
| `success?` | boolean | Whether the request succeeded |
| `links` | array | Array of discovered links |

### Link Objects

Each link in the results has these accessors:

| Accessor | Type | Description |
|----------|------|-------------|
| `url` | string | The discovered URL |
| `title` | string | Page title (if available) |
| `description` | string | Page description (if available) |

### Iteration

You can iterate over results directly:

```ruby
result.each do | link |
  puts "#{ link.url } - #{ link.title }"
end

# or access by index
first_link = result[ 0 ]

# array methods
result.length   # number of links
result.empty?   # true if no links found
```

---

## Use Cases

### Discover Pages Before Scraping

Use map to find all pages, then scrape specific ones:

```ruby
# find all pages
map_request = Firecrawl::MapRequest.new( api_key: api_key )
map_response = map_request.submit( 'https://example.com', { limit: 1000 } )

# filter for blog posts
blog_urls = map_response.result.links
  .select { | link | link.url.include?( '/blog/' ) }
  .map( &:url )

# batch scrape the blog posts
scrape_request = Firecrawl::BatchScrapeRequest.new( api_key: api_key )
scrape_response = scrape_request.submit( blog_urls )
```

### Search for Specific Content

Find pages related to a topic:

```ruby
options = Firecrawl::MapOptions.build do
  search 'pricing'
  limit 50
end

response = request.submit( 'https://example.com', options )

response.result.each do | link |
  puts "#{ link.title }: #{ link.url }"
end
```
