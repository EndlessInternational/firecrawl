# Test Guidelines

## Running Tests

```bash
bin/test                              # run all tests
bin/test test/scrape_request_test.rb  # run specific test file
bin/test --vcr off                    # run with live requests (no cassettes)
bin/test --vcr record                 # record new cassettes
```

## Directory Structure

Tests are organized by component:

```
test/
├── test_helper.rb
├── README.md
├── fixtures/
│   └── cassettes/           # VCR recorded HTTP interactions
├── scrape_request_test.rb
├── scrape_options_test.rb
├── batch_scrape_request_test.rb
├── map_request_test.rb
└── crawl_request_test.rb
```

## Naming Conventions

### Files

- use snake_case for file names
- suffix all test files with `_test.rb`
- name files after the component being tested

### Classes

- class names should end with `Test`
  - `class ScrapeRequestTest < Minitest::Test`

### Test Methods

- prefix all test methods with `test_`
- use descriptive names that explain what is being tested
- avoid abbreviations

```ruby
# good
def test_scrape_with_html_format_returns_html
def test_pdf_format_accepts_symbol_and_normalizes

# bad
def test_html_fmt
def test_pdf_sym
```

## Code Style

### Spacing

follow project CODESTYLE.md:
- spaces inside parentheses: `method( arg )`
- spaces inside brackets: `array[ index ]`
- spaces inside block braces: `{ | block | ... }`

### Comments

- keep comments minimal
- use lowercase for comments
- explain why, not what

```ruby
# good
# vcr cassette not available, skip in CI
skip if ENV[ 'CI' ]

# bad
# Skip the test if running in CI environment
skip if ENV[ 'CI' ]
```

## VCR Cassettes

Tests use VCR to record and replay HTTP interactions:

```ruby
def test_scrape_returns_markdown
  vcr_cassette do
    response = scrape_request.submit( @url )
    assert response.success?
  end
end
```

Cassette names are auto-generated from the test class and method name.

To record new cassettes:
```bash
bin/test --vcr record test/scrape_request_test.rb
```

## Test Helpers

Helpers are defined in `test_helper.rb`:

```ruby
class Minitest::Test
  def vcr_cassette( name = nil, options = {}, &block )
    # wraps test in VCR cassette
  end

  def assert_successful_response( response )
    # asserts Faraday response succeeded
  end
end
```
