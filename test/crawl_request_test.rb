require_relative 'test_helper'

class CrawlRequestTest < Minitest::Test

  def setup
    raise "A FIRECRAWL_API_KEY must be defined in the environment." unless ENV[ 'FIRECRAWL_API_KEY' ]
    @url = "https://www.iana.org"
  end

  def crawl_request
    @crawl_request ||= Firecrawl::CrawlRequest.new( api_key: ENV[ 'FIRECRAWL_API_KEY' ] )
  end

  # submit with minimal options

  def test_crawl_submit_with_minimal_options_returns_crawl_result
    vcr_cassette do
      options = Firecrawl::CrawlOptions.build do
        limit 3
      end

      response = crawl_request.submit( @url, options )

      assert_kind_of Faraday::Response, response
      assert_successful_response response
      assert_kind_of Firecrawl::CrawlResult, response.result

      result = response.result
      assert result.success?
      refute_nil result.id
      refute_nil result.url
    end
  end

  # submit with limit

  def test_crawl_submit_with_limit
    vcr_cassette do
      options = Firecrawl::CrawlOptions.build do
        limit 5
      end

      response = crawl_request.submit( @url, options )

      assert_successful_response response
      result = response.result
      assert result.success?
      refute_nil result.id
    end
  end

  # submit with scrape_options

  def test_crawl_submit_with_scrape_options
    vcr_cassette do
      options = Firecrawl::CrawlOptions.build do
        limit 3
        scrape_options do
          formats [ :markdown ]
          only_main_content true
        end
      end

      response = crawl_request.submit( @url, options )

      assert_successful_response response
      result = response.result
      assert result.success?
      refute_nil result.id
    end
  end

  # submit with path filters

  def test_crawl_submit_with_include_paths
    vcr_cassette do
      options = Firecrawl::CrawlOptions.build do
        limit 5
        include_paths [ '/help.*' ]
      end

      response = crawl_request.submit( @url, options )

      assert_successful_response response
      result = response.result
      assert result.success?
    end
  end

  def test_crawl_submit_with_exclude_paths
    vcr_cassette do
      options = Firecrawl::CrawlOptions.build do
        limit 5
        exclude_paths [ '/about.*' ]
      end

      response = crawl_request.submit( @url, options )

      assert_successful_response response
      result = response.result
      assert result.success?
    end
  end

  # submit with maximum_depth

  def test_crawl_submit_with_maximum_depth
    vcr_cassette do
      options = Firecrawl::CrawlOptions.build do
        limit 5
        maximum_depth 1
      end

      response = crawl_request.submit( @url, options )

      assert_successful_response response
      result = response.result
      assert result.success?
    end
  end

  # retrieve

  def test_crawl_retrieve_returns_results
    vcr_cassette do
      options = Firecrawl::CrawlOptions.build do
        limit 3
      end

      response = crawl_request.submit( @url, options )
      assert_successful_response response

      result = response.result
      assert result.success?

      # poll until completed or we have data
      attempts = 0
      while ( result.status.nil? || result.crawling? ) && attempts < 30
        sleep 2 if VCR_MODE == 'off'
        response = crawl_request.retrieve( result )
        assert_successful_response response
        result = response.result
        attempts += 1
      end

      # should have completed or still crawling
      assert_includes [ :scraping, :completed ], result.status

      # if completed, check results
      if result.completed?
        refute_empty result.data
        result.each do | scrape_result |
          refute_nil scrape_result.metadata
        end
      end
    end
  end

  # status helpers

  def test_crawl_status_helpers
    vcr_cassette do
      options = Firecrawl::CrawlOptions.build do
        limit 3
      end

      response = crawl_request.submit( @url, options )
      assert_successful_response response

      result = response.result
      assert result.success?

      # retrieve to get status
      response = crawl_request.retrieve( result )
      assert_successful_response response
      result = response.result

      # status should be one of the valid statuses
      assert_includes Firecrawl::CrawlResult::STATUSES, result.status

      # status? helper should work
      assert result.status?( result.status )
      refute result.status?( :invalid_status )
    end
  end

  # sitemap modes

  def test_crawl_with_sitemap_include
    vcr_cassette do
      options = Firecrawl::CrawlOptions.build do
        limit 3
        sitemap :include
      end

      response = crawl_request.submit( @url, options )

      assert_successful_response response
      result = response.result
      assert result.success?
    end
  end

  def test_crawl_with_sitemap_skip
    vcr_cassette do
      options = Firecrawl::CrawlOptions.build do
        limit 3
        sitemap :skip
      end

      response = crawl_request.submit( @url, options )

      assert_successful_response response
      result = response.result
      assert result.success?
    end
  end

  # ignore_query_parameters

  def test_crawl_with_ignore_query_parameters
    vcr_cassette do
      options = Firecrawl::CrawlOptions.build do
        limit 3
        ignore_query_parameters true
      end

      response = crawl_request.submit( @url, options )

      assert_successful_response response
      result = response.result
      assert result.success?
    end
  end

end
