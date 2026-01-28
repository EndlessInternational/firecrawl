require_relative 'test_helper'

class ExtractRequestTest < Minitest::Test

  def setup
    raise "A FIRECRAWL_API_KEY must be defined in the environment." unless ENV[ 'FIRECRAWL_API_KEY' ]
    @url = "https://www.iana.org"
  end

  def extract_request
    @extract_request ||= Firecrawl::ExtractRequest.new( api_key: ENV[ 'FIRECRAWL_API_KEY' ] )
  end

  # submit with prompt

  def test_extract_submit_with_prompt_returns_extract_result
    vcr_cassette do
      options = Firecrawl::ExtractOptions.build do
        prompt 'Extract the main heading and description from this page'
      end

      response = extract_request.submit( @url, options )

      assert_kind_of Faraday::Response, response
      assert_successful_response response
      assert_kind_of Firecrawl::ExtractResult, response.result

      result = response.result
      assert result.success?
      refute_nil result.id
    end
  end

  # submit with schema

  def test_extract_submit_with_schema
    vcr_cassette do
      options = Firecrawl::ExtractOptions.build do
        prompt 'Extract organization information'
        schema( {
          type: 'object',
          properties: {
            name: { type: 'string' },
            description: { type: 'string' }
          }
        } )
      end

      response = extract_request.submit( @url, options )

      assert_successful_response response
      result = response.result
      assert result.success?
      refute_nil result.id
    end
  end

  # submit with show_sources

  def test_extract_submit_with_show_sources
    vcr_cassette do
      options = Firecrawl::ExtractOptions.build do
        prompt 'What is this website about?'
        show_sources true
      end

      response = extract_request.submit( @url, options )

      assert_successful_response response
      result = response.result
      assert result.success?
    end
  end

  # submit with enable_web_search

  def test_extract_submit_with_web_search
    vcr_cassette do
      options = Firecrawl::ExtractOptions.build do
        prompt 'Find information about IANA'
        enable_web_search true
      end

      response = extract_request.submit( @url, options )

      assert_successful_response response
      result = response.result
      assert result.success?
    end
  end

  # retrieve

  def test_extract_retrieve_returns_results
    vcr_cassette do
      options = Firecrawl::ExtractOptions.build do
        prompt 'Extract the page title'
      end

      response = extract_request.submit( @url, options )
      assert_successful_response response

      result = response.result
      assert result.success?

      # poll until completed
      attempts = 0
      while ( result.status.nil? || result.processing? ) && attempts < 30
        sleep 2 if VCR_MODE == 'off'
        response = extract_request.retrieve( result )
        assert_successful_response response
        result = response.result
        attempts += 1
      end

      # should have completed or still processing
      assert_includes [ :processing, :completed ], result.status

      # if completed, check data
      if result.completed?
        refute_nil result.data
      end
    end
  end

  # status helpers

  def test_extract_status_helpers
    vcr_cassette do
      options = Firecrawl::ExtractOptions.build do
        prompt 'Extract the page title'
      end

      response = extract_request.submit( @url, options )
      assert_successful_response response

      result = response.result
      assert result.success?

      # retrieve to get status
      response = extract_request.retrieve( result )
      assert_successful_response response
      result = response.result

      # status should be one of the valid statuses
      assert_includes Firecrawl::ExtractResult::STATUSES, result.status

      # status? helper should work
      assert result.status?( result.status )
      refute result.status?( :invalid_status )
    end
  end

  # with scrape_options

  def test_extract_with_scrape_options
    vcr_cassette do
      options = Firecrawl::ExtractOptions.build do
        prompt 'Extract the main content'
        scrape_options do
          only_main_content true
          timeout 60000
        end
      end

      response = extract_request.submit( @url, options )

      assert_successful_response response
      result = response.result
      assert result.success?
    end
  end

  # multiple urls

  def test_extract_with_multiple_urls
    vcr_cassette do
      urls = [
        "https://www.iana.org",
        "https://www.iana.org/about"
      ]

      options = Firecrawl::ExtractOptions.build do
        prompt 'What are these pages about?'
      end

      response = extract_request.submit( urls, options )

      assert_successful_response response
      result = response.result
      assert result.success?
    end
  end

end
