require_relative 'test_helper'

class ExtractOptionsTest < Minitest::Test

  def test_build_with_prompt
    options = Firecrawl::ExtractOptions.build do
      prompt 'Extract contact information'
    end

    assert_equal 'Extract contact information', options.to_h[ :prompt ]
  end

  def test_build_with_schema
    schema_def = {
      type: 'object',
      properties: {
        name: { type: 'string' },
        email: { type: 'string' }
      }
    }

    options = Firecrawl::ExtractOptions.build do
      schema schema_def
    end

    assert_equal schema_def, options.to_h[ :schema ]
  end

  def test_build_with_enable_web_search
    options = Firecrawl::ExtractOptions.build do
      enable_web_search true
    end

    assert_equal true, options.to_h[ :enableWebSearch ]
  end

  def test_build_with_show_sources
    options = Firecrawl::ExtractOptions.build do
      show_sources true
    end

    assert_equal true, options.to_h[ :showSources ]
  end

  def test_build_with_ignore_sitemap
    options = Firecrawl::ExtractOptions.build do
      ignore_sitemap true
    end

    assert_equal true, options.to_h[ :ignoreSitemap ]
  end

  def test_build_with_include_subdomains
    options = Firecrawl::ExtractOptions.build do
      include_subdomains false
    end

    assert_equal false, options.to_h[ :includeSubdomains ]
  end

  def test_build_with_ignore_invalid_urls
    options = Firecrawl::ExtractOptions.build do
      ignore_invalid_urls true
    end

    assert_equal true, options.to_h[ :ignoreInvalidURLs ]
  end

  def test_build_with_scrape_options
    options = Firecrawl::ExtractOptions.build do
      prompt 'Extract data'
      scrape_options do
        only_main_content true
        timeout 60000
        mobile false
      end
    end

    hash = options.to_h
    assert_equal 'Extract data', hash[ :prompt ]

    scrape = hash[ :scrapeOptions ]
    assert_equal true, scrape[ :onlyMainContent ]
    assert_equal 60000, scrape[ :timeout ]
    assert_equal false, scrape[ :mobile ]
  end

  def test_build_with_combined_options
    schema_def = {
      type: 'object',
      properties: {
        title: { type: 'string' }
      }
    }

    options = Firecrawl::ExtractOptions.build do
      prompt 'Extract the page title'
      schema schema_def
      show_sources true
      include_subdomains false
    end

    hash = options.to_h
    assert_equal 'Extract the page title', hash[ :prompt ]
    assert_equal schema_def, hash[ :schema ]
    assert_equal true, hash[ :showSources ]
    assert_equal false, hash[ :includeSubdomains ]
  end

  def test_build_with_hash
    options = Firecrawl::ExtractOptions.build( {
      prompt: 'Extract info',
      enable_web_search: true,
      show_sources: true
    } )

    hash = options.to_h
    assert_equal 'Extract info', hash[ :prompt ]
    assert_equal true, hash[ :enableWebSearch ]
    assert_equal true, hash[ :showSources ]
  end

end
