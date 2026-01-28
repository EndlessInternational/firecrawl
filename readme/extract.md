# Extract

The extract endpoint uses LLM to pull structured data from one or more URLs. You provide URLs (optionally with glob patterns), a prompt and/or JSON schema, and Firecrawl returns structured data matching your requirements.

## Basic Usage

```ruby
request = Firecrawl::ExtractRequest.new( api_key: ENV[ 'FIRECRAWL_API_KEY' ] )

options = Firecrawl::ExtractOptions.build do
  prompt 'Extract the company name and description'
end

response = request.submit( 'https://example.com', options )

while response.success?
  result = response.result
  break unless result.processing?
  sleep 2
  response = request.retrieve( result )
end

if result.completed?
  puts result.data
end
```

## Options

Options can be passed as a hash or built using the DSL:

```ruby
# using DSL
options = Firecrawl::ExtractOptions.build do
  prompt 'Extract product information'
  schema( {
    type: 'object',
    properties: {
      name: { type: 'string' },
      price: { type: 'number' },
      description: { type: 'string' }
    }
  } )
  show_sources true
end

# using hash
options = {
  prompt: 'Extract product information',
  schema: { type: 'object', properties: { name: { type: 'string' } } }
}

response = request.submit( urls, options )
```

---

## Extraction Options

### Prompt

Provide natural language guidance for the extraction:

```ruby
options = Firecrawl::ExtractOptions.build do
  prompt 'Extract all contact information including email, phone, and address'
end
```

### Schema

Define the structure of extracted data using JSON Schema:

```ruby
options = Firecrawl::ExtractOptions.build do
  prompt 'Extract product details'
  schema( {
    type: 'object',
    properties: {
      name: { type: 'string', description: 'Product name' },
      price: { type: 'number', description: 'Price in USD' },
      features: {
        type: 'array',
        items: { type: 'string' }
      }
    },
    required: [ 'name', 'price' ]
  } )
end
```

### Web Search

Enable web search to find additional data:

```ruby
options = Firecrawl::ExtractOptions.build do
  prompt 'Find information about this company'
  enable_web_search true
end
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `prompt` | string | none | Natural language guidance for extraction |
| `schema` | hash | none | JSON Schema defining the structure of extracted data |
| `enable_web_search` | boolean | false | Use web search to find additional data |
| `show_sources` | boolean | false | Include sources used for extraction in response |

---

## URL Handling

```ruby
options = Firecrawl::ExtractOptions.build do
  prompt 'Extract data'
  include_subdomains true
  ignore_sitemap false
  ignore_invalid_urls true
end
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `include_subdomains` | boolean | true | Scan subdomains of provided URLs |
| `ignore_sitemap` | boolean | false | Ignore sitemap.xml during scanning |
| `ignore_invalid_urls` | boolean | true | Ignore invalid URLs instead of failing |

### Glob Patterns

URLs can include glob patterns to match multiple pages:

```ruby
urls = [
  'https://example.com/blog/*',
  'https://example.com/products/**'
]

response = request.submit( urls, options )
```

---

## Scrape Options

Configure how pages are scraped before extraction:

```ruby
options = Firecrawl::ExtractOptions.build do
  prompt 'Extract the main content'
  scrape_options do
    only_main_content true
    timeout 60000
    mobile false
    block_ads true
  end
end
```

All options from [scrape](scrape.md) are available within `scrape_options`.

---

## Polling for Results

After submitting an extraction, poll for results:

```ruby
response = request.submit( urls, options )

while response.success?
  result = response.result

  case result.status
  when :completed
    puts "Extracted data: #{ result.data }"
    puts "Tokens used: #{ result.tokens_used }"
    break
  when :failed
    puts "Extraction failed"
    break
  when :processing
    sleep 2
    response = request.retrieve( result )
  end
end
```

---

## Response

When the request succeeds, `response.result` is an `ExtractResult` object.

### Result Accessors

| Accessor | Type | Description |
|----------|------|-------------|
| `id` | string | The extract job ID |
| `status` | symbol | Current status: `:processing`, `:completed`, `:failed`, or `:cancelled` |
| `expires_at` | string | When the extracted data expires |
| `tokens_used` | integer | Number of tokens used (only when completed) |
| `data` | hash | The extracted structured data |
| `sources` | array | Sources used for extraction (if `show_sources` was true) |

### Status Helpers

```ruby
result = response.result

result.success?      # true if the API call succeeded
result.processing?   # true if status is :processing
result.completed?    # true if status is :completed
result.failed?       # true if status is :failed
result.cancelled?    # true if status is :cancelled
result.status?( :processing )  # check for specific status
```

### Sources

When `show_sources` is enabled, you can access the sources:

```ruby
result.sources.each do | source |
  puts "#{ source.title }: #{ source.url }"
end
```

---

## Use Cases

### Extract Contact Information

```ruby
options = Firecrawl::ExtractOptions.build do
  prompt 'Extract all contact information'
  schema( {
    type: 'object',
    properties: {
      email: { type: 'string' },
      phone: { type: 'string' },
      address: { type: 'string' }
    }
  } )
end

response = request.submit( 'https://example.com/contact', options )
```

### Extract Product Catalog

```ruby
options = Firecrawl::ExtractOptions.build do
  prompt 'Extract all products with their prices and descriptions'
  schema( {
    type: 'object',
    properties: {
      products: {
        type: 'array',
        items: {
          type: 'object',
          properties: {
            name: { type: 'string' },
            price: { type: 'number' },
            description: { type: 'string' }
          }
        }
      }
    }
  } )
end

response = request.submit( 'https://example.com/products/*', options )
```

### Research with Web Search

```ruby
options = Firecrawl::ExtractOptions.build do
  prompt 'Find the founding date and founders of this company'
  enable_web_search true
  show_sources true
end

response = request.submit( 'https://example.com', options )
```
