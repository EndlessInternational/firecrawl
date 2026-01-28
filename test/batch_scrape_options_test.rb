require_relative 'test_helper'

class BatchScrapeOptionsTest < Minitest::Test

  # batch-specific options

  def test_build_with_max_concurrency
    options = Firecrawl::BatchScrapeOptions.build do
      max_concurrency 10
    end

    assert_equal 10, options.to_h[ :maxConcurrency ]
  end

  def test_build_with_ignore_invalid_urls
    options = Firecrawl::BatchScrapeOptions.build do
      ignore_invalid_urls true
    end

    assert_equal true, options.to_h[ :ignoreInvalidURLs ]
  end

  def test_build_with_webhook
    options = Firecrawl::BatchScrapeOptions.build do
      webhook do
        url 'https://example.com/webhook'
        headers( { 'Authorization' => 'Bearer token' } )
        metadata( { job_id: '123' } )
        events [ :completed, :page, :failed ]
      end
    end

    webhook = options.to_h[ :webhook ]
    assert_equal 'https://example.com/webhook', webhook[ :url ]
    assert_equal( { 'Authorization' => 'Bearer token' }, webhook[ :headers ] )
    assert_equal( { job_id: '123' }, webhook[ :metadata ] )
    assert_equal [ :completed, :page, :failed ], webhook[ :events ]
  end

  # inherited scrape options

  def test_build_with_formats
    options = Firecrawl::BatchScrapeOptions.build do
      formats [ :markdown, :html ]
    end

    assert_equal [ :markdown, :html ], options.to_h[ :formats ]
  end

  def test_build_with_only_main_content
    options = Firecrawl::BatchScrapeOptions.build do
      only_main_content false
    end

    assert_equal false, options.to_h[ :onlyMainContent ]
  end

  def test_build_with_timeout
    options = Firecrawl::BatchScrapeOptions.build do
      timeout 60000
    end

    assert_equal 60000, options.to_h[ :timeout ]
  end

  def test_build_with_mobile
    options = Firecrawl::BatchScrapeOptions.build do
      mobile true
    end

    assert_equal true, options.to_h[ :mobile ]
  end

  def test_build_with_location
    options = Firecrawl::BatchScrapeOptions.build do
      location 'DE' do
        languages [ 'de-DE', 'de' ]
      end
    end

    location = options.to_h[ :location ]
    assert_equal 'DE', location[ :country ]
    assert_equal [ 'de-DE', 'de' ], location[ :languages ]
  end

  def test_build_with_action
    options = Firecrawl::BatchScrapeOptions.build do
      action :click do
        selector '#button'
      end
    end

    actions = options.to_h[ :actions ]
    assert_equal 1, actions.length
    assert_equal :click, actions.first[ :type ]
    assert_equal '#button', actions.first[ :selector ]
  end

  # combined batch and scrape options

  def test_build_with_combined_options
    options = Firecrawl::BatchScrapeOptions.build do
      max_concurrency 5
      ignore_invalid_urls true
      formats [ :markdown ]
      only_main_content true
      timeout 30000
    end

    hash = options.to_h
    assert_equal 5, hash[ :maxConcurrency ]
    assert_equal true, hash[ :ignoreInvalidURLs ]
    assert_equal [ :markdown ], hash[ :formats ]
    assert_equal true, hash[ :onlyMainContent ]
    assert_equal 30000, hash[ :timeout ]
  end

  # normalize_options delegates to ScrapeOptions

  def test_normalize_options_with_screenshot
    options = {
      formats: [ :markdown ],
      screenshot: { type: 'screenshot', fullPage: true }
    }

    normalized = Firecrawl::BatchScrapeOptions.normalize_options( options )

    assert_includes normalized[ :formats ], { type: 'screenshot', fullPage: true }
    refute_includes normalized[ :formats ], :screenshot
  end

end
