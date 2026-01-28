require_relative 'test_helper'

class BatchScrapeRequestTest < Minitest::Test

  def setup
    raise "A FIRECRAWL_API_KEY must be defined in the environment." unless ENV[ 'FIRECRAWL_API_KEY' ]
    @urls = [
      "https://www.iana.org/help/example-domains",
      "https://www.iana.org/domains/reserved"
    ]
  end

  def batch_scrape_request
    @batch_scrape_request ||= Firecrawl::BatchScrapeRequest.new( api_key: ENV[ 'FIRECRAWL_API_KEY' ] )
  end

  # submit with no options

  def test_batch_scrape_submit_with_no_options_returns_batch_result
    vcr_cassette do
      response = batch_scrape_request.submit( @urls )

      assert_kind_of Faraday::Response, response
      assert_successful_response response
      assert_kind_of Firecrawl::BatchScrapeResult, response.result

      result = response.result
      assert result.success?
      refute_nil result.id
      refute_nil result.url
    end
  end

  # submit with formats

  def test_batch_scrape_submit_with_markdown_format
    vcr_cassette do
      options = Firecrawl::BatchScrapeOptions.build do
        formats [ :markdown ]
        only_main_content true
      end

      response = batch_scrape_request.submit( @urls, options )

      assert_successful_response response
      result = response.result
      assert result.success?
      refute_nil result.id
    end
  end

  def test_batch_scrape_submit_with_html_and_markdown_formats
    vcr_cassette do
      options = Firecrawl::BatchScrapeOptions.build do
        formats [ :html, :markdown ]
        only_main_content false
      end

      response = batch_scrape_request.submit( @urls, options )

      assert_successful_response response
      result = response.result
      assert result.success?
      refute_nil result.id
    end
  end

  # retrieve

  def test_batch_scrape_retrieve_returns_results
    vcr_cassette do
      response = batch_scrape_request.submit( @urls )
      assert_successful_response response

      result = response.result
      assert result.success?

      # poll until completed or we have data
      attempts = 0
      while ( result.status.nil? || result.scraping? ) && attempts < 30
        sleep 2 if VCR_MODE == 'off'
        response = batch_scrape_request.retrieve( result )
        assert_successful_response response
        result = response.result
        attempts += 1
      end

      # should have completed
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

  def test_batch_scrape_status_helpers
    vcr_cassette do
      response = batch_scrape_request.submit( @urls )
      assert_successful_response response

      result = response.result
      assert result.success?

      # retrieve to get status
      response = batch_scrape_request.retrieve( result )
      assert_successful_response response
      result = response.result

      # status should be one of the valid statuses
      assert_includes Firecrawl::BatchScrapeResult::STATUSES, result.status

      # status? helper should work
      assert result.status?( result.status )
      refute result.status?( :invalid_status )
    end
  end

  # retrieve_all

  def test_batch_scrape_retrieve_all_returns_all_results
    vcr_cassette do
      response = batch_scrape_request.submit( @urls )
      assert_successful_response response

      result = response.result
      assert result.success?

      # poll until completed
      attempts = 0
      while ( result.status.nil? || result.scraping? ) && attempts < 30
        sleep 2 if VCR_MODE == 'off'
        response = batch_scrape_request.retrieve( result )
        assert_successful_response response
        result = response.result
        attempts += 1
      end

      # now call retrieve_all to get all results again
      response = batch_scrape_request.retrieve_all( result )
      assert_successful_response response

      all_result = response.result
      assert all_result.success?
    end
  end

end
