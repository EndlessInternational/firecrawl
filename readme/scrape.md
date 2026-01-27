# Scrape

The scrape endpoint fetches a single URL and returns the page content in one or more formats. You can configure output formats, content filtering, browser emulation, and execute browser actions before capturing content.

## Basic Usage

```ruby
request = Firecrawl::ScrapeRequest.new( api_key: ENV[ 'FIRECRAWL_API_KEY' ] )
response = request.submit( 'https://example.com' )

if response.success?
  result = response.result
  puts result.markdown
end
```

## Options

Options can be passed as a hash or built using the DSL:

```ruby
# using DSL
options = Firecrawl::ScrapeOptions.build do
  formats [ :markdown, :html ]
  only_main_content true
end

# using hash
options = { formats: [ :markdown, :html ], only_main_content: true }

response = request.submit( url, options )
```

---

## Output Formats

The `formats` option specifies which content formats to include in the response. By default, only markdown is returned.

```ruby
options = Firecrawl::ScrapeOptions.build do
  formats [ :markdown, :html, :raw_html, :links, :screenshot ]
end
```

### Available Formats

| Format | Description |
|--------|-------------|
| `:markdown` | The page content converted to Markdown |
| `:summary` | A summary of the page content |
| `:html` | The processed HTML content |
| `:raw_html` | The original HTML before processing |
| `:links` | An array of links found on the page |
| `:images` | An array of image URLs found on the page |
| `:screenshot` | A screenshot of the page (returns a URL) |
| `:branding` | Extracted brand tokens such as colors and fonts |

### Screenshot Options

When requesting screenshots, you can specify additional options:

```ruby
options = Firecrawl::ScrapeOptions.build do
  screenshot do
    full_page true
    quality 80
    viewport do
      width 1920
      height 1080
    end
  end
end
```

| Option | Type | Description |
|--------|------|-------------|
| `full_page` | boolean | Capture the entire scrollable page |
| `quality` | integer | Image quality from 0 to 100 |
| `viewport` | object | Custom viewport dimensions with `width` and `height` |

### JSON Extraction

The JSON format uses an LLM to extract structured data from the page according to a schema you provide:

```ruby
options = Firecrawl::ScrapeOptions.build do
  json do
    schema( {
      type: 'object',
      properties: {
        title: { type: 'string' },
        price: { type: 'number' },
        in_stock: { type: 'boolean' }
      }
    } )
    prompt 'Extract the product details from this page'
  end
end
```

| Option | Type | Description |
|--------|------|-------------|
| `schema` | hash | A JSON Schema defining the structure to extract |
| `prompt` | string | Instructions for the LLM extraction |

The extracted data is available in `result.extract`.

### Change Tracking

The change tracking format compares the current scrape against previous scrapes of the same URL:

```ruby
options = Firecrawl::ScrapeOptions.build do
  change_tracking do
    modes [ :'git-diff', :json ]
    tag 'production'
  end
end
```

| Option | Type | Description |
|--------|------|-------------|
| `modes` | array | Comparison modes: `:'git-diff'` and/or `:json` |
| `schema` | hash | JSON Schema for structured comparison (with `:json` mode) |
| `prompt` | string | Instructions for comparison (with `:json` mode) |
| `tag` | string | Tag for separating change tracking history |

Results are available in `result.change_tracking`.

---

## Content Filtering

These options control which content is included in the response.

```ruby
options = Firecrawl::ScrapeOptions.build do
  only_main_content true
  include_tags [ 'article', 'main' ]
  exclude_tags [ 'nav', 'footer', 'aside' ]
  remove_base64_images true
  block_ads true
end
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `only_main_content` | boolean | true | Attempt to return only the main article content, excluding navigation, headers, and footers |
| `include_tags` | array | none | Only include content from these HTML tags |
| `exclude_tags` | array | none | Exclude content from these HTML tags |
| `remove_base64_images` | boolean | true | Replace base64 images with placeholders to reduce response size |
| `block_ads` | boolean | true | Enable ad blocking and cookie popup blocking |

---

## Timing and Caching

```ruby
options = Firecrawl::ScrapeOptions.build do
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
| `cache` | boolean | true | Whether to store the page in Firecrawl's cache |

---

## Network and Browser

```ruby
options = Firecrawl::ScrapeOptions.build do
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
| `headers` | hash | none | Custom HTTP headers to send with the request |
| `location` | object | none | Location settings with `country` (ISO 3166-1 alpha-2 code) and `languages` |

### Proxy Modes

| Mode | Description |
|------|-------------|
| `:basic` | Standard proxy, lower cost |
| `:stealth` | Advanced proxy for difficult targets, higher cost |
| `:auto` | Starts with basic, retries with stealth if needed |

---

## File Parsing

The `parsers` option configures how files like PDFs are processed:

```ruby
options = Firecrawl::ScrapeOptions.build do
  parsers do
    type :pdf
    max_pages 50
  end
end
```

| Option | Type | Description |
|--------|------|-------------|
| `type` | symbol | Parser type, currently only `:pdf` |
| `max_pages` | integer | Maximum number of pages to parse (1-10000) |

When PDF parsing is enabled, Firecrawl extracts text into Markdown. The cost is billed per page.

---

## Browser Actions

Browser actions allow you to interact with the page before content is captured. Actions are executed in sequence in a real browser.

```ruby
options = Firecrawl::ScrapeOptions.build do
  action :wait do
    milliseconds 1000
  end
  action :click do
    selector '#load-more'
  end
  action :screenshot do
    full_page true
  end
end
```

### Available Actions

#### wait

Wait for a duration or for an element to appear:

```ruby
action :wait do
  milliseconds 2000
end

action :wait do
  selector '.content-loaded'
end
```

#### click

Click an element. Use `all: true` to click all matching elements:

```ruby
action :click do
  selector 'button.accept'
  all true
end
```

#### write

Type text into the focused element:

```ruby
action :write do
  text 'search query'
end
```

#### press

Press a keyboard key:

```ruby
action :press do
  key 'Enter'
end
```

#### scroll

Scroll the page or an element:

```ruby
action :scroll do
  direction :down
  selector '#content'
end
```

| Option | Values |
|--------|--------|
| `direction` | `:up`, `:down` |

#### screenshot

Capture a screenshot at this point in the action sequence:

```ruby
action :screenshot do
  full_page true
  quality 90
end
```

#### scrape

Capture the current page HTML at this point:

```ruby
action :scrape
```

#### execute_javascript

Run JavaScript code on the page:

```ruby
action :execute_javascript do
  script 'document.querySelector(".popup").remove()'
end
```

#### pdf

Generate a PDF of the current page:

```ruby
action :pdf do
  format :A4
  landscape true
  scale 0.8
end
```

| Option | Type | Description |
|--------|------|-------------|
| `format` | string | Page format: A0-A6, Letter, Legal, Tabloid, Ledger |
| `landscape` | boolean | Use landscape orientation |
| `scale` | float | Scale factor for rendering |

---

## Data Retention

```ruby
options = Firecrawl::ScrapeOptions.build do
  zero_retention true
end
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `zero_retention` | boolean | false | Enable zero data retention (requires account configuration) |

---

## Response

When the request succeeds, `response.result` is a `ScrapeResult` object with the following accessors:

### Content

| Accessor | Type | Description |
|----------|------|-------------|
| `markdown` | string | The page content as Markdown |
| `summary` | string | A summary of the page content |
| `html` | string | The processed HTML content |
| `raw_html` | string | The original unprocessed HTML |
| `screenshot_url` | string | URL of the screenshot (expires after 24 hours) |
| `links` | array | Links found on the page |
| `images` | array | Image URLs found on the page |

### Metadata

| Accessor | Type | Description |
|----------|------|-------------|
| `metadata` | hash | Page metadata including title, description, language, and more |

The metadata hash includes keys like `title`, `description`, `language`, `source_url`, `status_code`, and any Open Graph or other meta tags found on the page. Keys are normalized to snake_case.

### Extraction Results

| Accessor | Type | Description |
|----------|------|-------------|
| `extract` | hash | Structured data from JSON extraction |
| `branding` | hash | Extracted brand tokens |
| `warning` | string | Warnings from LLM extraction |

### Action Results

| Accessor | Type | Description |
|----------|------|-------------|
| `actions` | object | Results from browser actions |

The actions object contains:

| Field | Type | Description |
|-------|------|-------------|
| `screenshots` | array | URLs of screenshots captured during actions |
| `scrapes` | array | HTML captured at scrape action points (objects with `url` and `html`) |
| `javascript_returns` | array | Return values from JavaScript execution (objects with `type` and `value`) |
| `pdfs` | array | URLs of PDFs generated during actions |

### Change Tracking

| Accessor | Type | Description |
|----------|------|-------------|
| `change_tracking` | object | Change tracking results |

The change tracking object contains:

| Field | Type | Description |
|-------|------|-------------|
| `previous_scrape_at` | string | ISO 8601 timestamp of the previous scrape |
| `change_status` | symbol | Status: `:new`, `:same`, `:changed`, or `:removed` |
| `visibility` | symbol | Visibility: `:visible` or `:hidden` |
| `diff` | string | Git-style diff (when using git-diff mode) |
| `json` | hash | JSON comparison results (when using json mode) |

### Success Check

```ruby
result = response.result
if result.success?
  puts result.markdown
end
```
