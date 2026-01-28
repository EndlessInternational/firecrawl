require_relative 'test_helper'

class MapRequestTest < Minitest::Test

  def setup
    raise "A FIRECRAWL_API_KEY must be defined in the environment." unless ENV[ 'FIRECRAWL_API_KEY' ]
    @url = "https://www.iana.org"
  end

  def map_request
    @map_request ||= Firecrawl::MapRequest.new( api_key: ENV[ 'FIRECRAWL_API_KEY' ] )
  end

  # no options

  def test_map_with_no_options_returns_links
    vcr_cassette do
      response = map_request.submit( @url )

      assert_kind_of Faraday::Response, response
      assert_successful_response response
      assert_kind_of Firecrawl::MapResult, response.result

      result = response.result
      assert result.success?
      refute_empty result.links
    end
  end

  # with limit

  def test_map_with_limit_returns_limited_links
    vcr_cassette do
      options = Firecrawl::MapOptions.build do
        limit 10
      end

      response = map_request.submit( @url, options )

      assert_successful_response response
      result = response.result
      assert result.success?
      refute_empty result.links
      assert result.links.length <= 10
    end
  end

  # with search

  def test_map_with_search_filters_links
    vcr_cassette do
      options = Firecrawl::MapOptions.build do
        search 'domains'
        limit 50
      end

      response = map_request.submit( @url, options )

      assert_successful_response response
      result = response.result
      assert result.success?
    end
  end

  # with include_subdomains

  def test_map_with_include_subdomains_false
    vcr_cassette do
      options = Firecrawl::MapOptions.build do
        include_subdomains false
        limit 20
      end

      response = map_request.submit( @url, options )

      assert_successful_response response
      result = response.result
      assert result.success?
    end
  end

  # with ignore_query_parameters

  def test_map_with_ignore_query_parameters
    vcr_cassette do
      options = Firecrawl::MapOptions.build do
        ignore_query_parameters true
        limit 20
      end

      response = map_request.submit( @url, options )

      assert_successful_response response
      result = response.result
      assert result.success?
    end
  end

  # with sitemap modes

  def test_map_with_sitemap_include
    vcr_cassette do
      options = Firecrawl::MapOptions.build do
        sitemap :include
        limit 20
      end

      response = map_request.submit( @url, options )

      assert_successful_response response
      result = response.result
      assert result.success?
    end
  end

  def test_map_with_sitemap_skip
    vcr_cassette do
      options = Firecrawl::MapOptions.build do
        sitemap :skip
        limit 20
      end

      response = map_request.submit( @url, options )

      assert_successful_response response
      result = response.result
      assert result.success?
    end
  end

  # accessing link data

  def test_map_links_have_url
    vcr_cassette do
      options = Firecrawl::MapOptions.build do
        limit 5
      end

      response = map_request.submit( @url, options )

      assert_successful_response response
      result = response.result
      assert result.success?
      refute_empty result.links

      result.each do | link |
        refute_nil link.url
      end
    end
  end

  # iteration helpers

  def test_map_result_iteration
    vcr_cassette do
      options = Firecrawl::MapOptions.build do
        limit 5
      end

      response = map_request.submit( @url, options )

      assert_successful_response response
      result = response.result
      assert result.success?

      # test array-like access
      refute_nil result[ 0 ] if result.length > 0

      # test each
      count = 0
      result.each { | _ | count += 1 }
      assert_equal result.length, count
    end
  end

end
