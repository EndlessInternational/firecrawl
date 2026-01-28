require_relative 'test_helper'

class CrawlOptionsTest < Minitest::Test

  def test_build_with_prompt
    options = Firecrawl::CrawlOptions.build do
      prompt 'Crawl all product pages'
    end

    assert_equal 'Crawl all product pages', options.to_h[ :prompt ]
  end

  def test_build_with_limit
    options = Firecrawl::CrawlOptions.build do
      limit 100
    end

    assert_equal 100, options.to_h[ :limit ]
  end

  def test_build_with_maximum_depth
    options = Firecrawl::CrawlOptions.build do
      maximum_depth 3
    end

    assert_equal 3, options.to_h[ :maxDiscoveryDepth ]
  end

  def test_build_with_include_paths
    options = Firecrawl::CrawlOptions.build do
      include_paths [ '/blog.*', '/docs.*' ]
    end

    assert_equal [ '/blog.*', '/docs.*' ], options.to_h[ :includePaths ]
  end

  def test_build_with_exclude_paths
    options = Firecrawl::CrawlOptions.build do
      exclude_paths [ '/admin.*', '/private.*' ]
    end

    assert_equal [ '/admin.*', '/private.*' ], options.to_h[ :excludePaths ]
  end

  def test_build_with_sitemap_modes
    [ :skip, :include, :only ].each do | mode |
      options = Firecrawl::CrawlOptions.build do
        sitemap mode
      end

      assert_equal mode, options.to_h[ :sitemap ]
    end
  end

  def test_build_with_domain_options
    options = Firecrawl::CrawlOptions.build do
      crawl_entire_domain true
      allow_external_links false
      allow_subdomains true
    end

    hash = options.to_h
    assert_equal true, hash[ :crawlEntireDomain ]
    assert_equal false, hash[ :allowExternalLinks ]
    assert_equal true, hash[ :allowSubdomains ]
  end

  def test_build_with_ignore_query_parameters
    options = Firecrawl::CrawlOptions.build do
      ignore_query_parameters true
    end

    assert_equal true, options.to_h[ :ignoreQueryParameters ]
  end

  def test_build_with_delay
    options = Firecrawl::CrawlOptions.build do
      delay 2.5
    end

    assert_equal 2.5, options.to_h[ :delay ]
  end

  def test_build_with_max_concurrency
    options = Firecrawl::CrawlOptions.build do
      max_concurrency 5
    end

    assert_equal 5, options.to_h[ :maxConcurrency ]
  end

  def test_build_with_webhook
    options = Firecrawl::CrawlOptions.build do
      webhook do
        url 'https://example.com/webhook'
        headers( { 'X-Secret' => 'abc123' } )
        events [ :completed, :page ]
      end
    end

    webhook = options.to_h[ :webhook ]
    assert_equal 'https://example.com/webhook', webhook[ :url ]
    assert_equal( { 'X-Secret' => 'abc123' }, webhook[ :headers ] )
    assert_equal [ :completed, :page ], webhook[ :events ]
  end

  def test_build_with_scrape_options
    options = Firecrawl::CrawlOptions.build do
      limit 10
      scrape_options do
        formats [ :markdown, :html ]
        only_main_content true
      end
    end

    hash = options.to_h
    assert_equal 10, hash[ :limit ]

    scrape = hash[ :scrapeOptions ]
    assert_equal [ :markdown, :html ], scrape[ :formats ]
    assert_equal true, scrape[ :onlyMainContent ]
  end

  def test_build_with_zero_data_retention
    options = Firecrawl::CrawlOptions.build do
      zero_data_retention true
    end

    assert_equal true, options.to_h[ :zeroDataRetention ]
  end

end
