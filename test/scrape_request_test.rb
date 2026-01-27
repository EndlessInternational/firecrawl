require_relative 'test_helper'

class ScrapeRequestTest < Minitest::Test

  def setup
    raise "A FIRECRAWL_API_KEY must be defined in the environment." unless ENV[ 'FIRECRAWL_API_KEY' ]
    @url = "https://www.iana.org/help/example-domains"
  end

  def scrape_request
    @scrape_request ||= Firecrawl::ScrapeRequest.new( api_key: ENV[ 'FIRECRAWL_API_KEY' ] )
  end

  # no options

  def test_scrape_with_no_options_returns_main_content_in_markdown
    vcr_cassette do
      response = scrape_request.submit( @url )

      assert_kind_of Faraday::Response, response
      assert_successful_response response
      assert_kind_of Firecrawl::ScrapeResult, response.result

      result = response.result
      assert result.success?
      assert_match( /example domains/i, result.metadata[ 'title' ] )

      refute_nil result.markdown
      assert_match( /number of domains such as example/, result.markdown )
      refute_match( /about/i, result.markdown )

      assert_nil result.html
      assert_nil result.raw_html
      assert_equal [], result.links
      assert_nil result.screenshot_url
      assert result.actions.empty?
      assert_nil result.warning
    end
  end

  # only_main_content false

  def test_scrape_with_only_main_content_false_returns_all_content
    vcr_cassette do
      options = Firecrawl::ScrapeOptions.build do
        only_main_content false
      end

      response = scrape_request.submit( @url, options )

      assert_successful_response response
      result = response.result
      assert result.success?
      assert_match( /example domains/i, result.metadata[ 'title' ] )

      refute_nil result.markdown
      assert_match( /number of domains such as example/i, result.markdown )
      assert_match( /about/i, result.markdown )

      assert_nil result.html
      assert_nil result.raw_html
      assert_equal [], result.links
      assert_nil result.screenshot_url
      assert result.actions.empty?
      assert_nil result.warning
    end
  end

  # only_main_content true

  def test_scrape_with_only_main_content_true_returns_main_content
    vcr_cassette do
      options = Firecrawl::ScrapeOptions.build do
        only_main_content true
      end

      response = scrape_request.submit( @url, options )

      assert_successful_response response
      result = response.result
      assert result.success?
      assert_match( /example domains/i, result.metadata[ 'title' ] )

      refute_nil result.markdown
      assert_match( /number of domains such as example/i, result.markdown )
      refute_match( /about/i, result.markdown )

      assert_nil result.html
      assert_nil result.raw_html
      assert_equal [], result.links
      assert_nil result.screenshot_url
      assert result.actions.empty?
      assert_nil result.warning
    end
  end

  # formats :html

  def test_scrape_with_html_format_and_only_main_content_false
    vcr_cassette do
      options = Firecrawl::ScrapeOptions.build do
        formats :html
        only_main_content false
      end

      response = scrape_request.submit( @url, options )

      assert_successful_response response
      result = response.result
      assert result.success?
      assert_match( /example domains/i, result.metadata[ 'title' ] )

      refute_nil result.html
      assert_match( /number of domains such as example/i, result.html )
      assert_match( /about/i, result.html )

      assert_nil result.markdown
      assert_nil result.raw_html
      assert_equal [], result.links
      assert_nil result.screenshot_url
      assert result.actions.empty?
      assert_nil result.warning
    end
  end

  def test_scrape_with_html_format_and_only_main_content_true
    vcr_cassette do
      options = Firecrawl::ScrapeOptions.build do
        formats :html
        only_main_content true
      end

      response = scrape_request.submit( @url, options )

      assert_successful_response response
      result = response.result
      assert result.success?
      assert_match( /example domains/i, result.metadata[ 'title' ] )

      refute_nil result.html
      assert_match( /number of domains such as example/i, result.html )
      refute_match( /about/i, result.html )

      assert_nil result.markdown
      assert_nil result.raw_html
      assert_equal [], result.links
      assert_nil result.screenshot_url
      assert result.actions.empty?
      assert_nil result.warning
    end
  end

  # formats [:html, :markdown]

  def test_scrape_with_html_and_markdown_formats_and_only_main_content_false
    vcr_cassette do
      options = Firecrawl::ScrapeOptions.build do
        formats [:html, :markdown]
        only_main_content false
      end

      response = scrape_request.submit( @url, options )

      assert_successful_response response
      result = response.result
      assert result.success?
      assert_match( /example domains/i, result.metadata[ 'title' ] )

      refute_nil result.html
      refute_nil result.markdown
      assert_match( /number of domains such as example/i, result.html )
      assert_match( /about/i, result.html )
      assert_match( /number of domains such as example/i, result.markdown )
      assert_match( /about/i, result.markdown )

      assert_nil result.raw_html
      assert_equal [], result.links
      assert_nil result.screenshot_url
      assert result.actions.empty?
      assert_nil result.warning
    end
  end

  def test_scrape_with_html_and_markdown_formats_and_only_main_content_true
    vcr_cassette do
      options = Firecrawl::ScrapeOptions.build do
        formats [:html, :markdown]
        only_main_content true
      end

      response = scrape_request.submit( @url, options )

      assert_successful_response response
      result = response.result
      assert result.success?
      assert_match( /example domains/i, result.metadata[ 'title' ] )

      refute_nil result.html
      refute_nil result.markdown
      assert_match( /number of domains such as example/i, result.html )
      refute_match( /about/i, result.html )
      assert_match( /number of domains such as example/i, result.markdown )
      refute_match( /about/i, result.markdown )

      assert_nil result.raw_html
      assert_equal [], result.links
      assert_nil result.screenshot_url
      assert result.actions.empty?
      assert_nil result.warning
    end
  end

  # formats :screenshot

  def test_scrape_with_screenshot_format
    vcr_cassette do
      options = Firecrawl::ScrapeOptions.build do
        formats :screenshot
      end

      response = scrape_request.submit( @url, options )

      assert_successful_response response
      result = response.result
      assert result.success?
      assert_match( /example domains/i, result.metadata[ 'title' ] )

      refute_nil result.screenshot_url

      assert_nil result.markdown
      assert_nil result.html
      assert_nil result.raw_html
      assert_equal [], result.links
      assert result.actions.empty?
      assert_nil result.warning
    end
  end

  # screenshot option (with full_page)

  def test_scrape_with_screenshot_option_full_page
    vcr_cassette do
      options = Firecrawl::ScrapeOptions.build do
        screenshot { full_page true }
      end

      response = scrape_request.submit( @url, options )

      assert_successful_response response
      result = response.result
      assert result.success?
      assert_match( /example domains/i, result.metadata[ 'title' ] )

      refute_nil result.screenshot_url

      assert_nil result.markdown
      assert_nil result.html
      assert_nil result.raw_html
      assert_equal [], result.links
      assert result.actions.empty?
      assert_nil result.warning
    end
  end

  # formats [:html, :markdown, :screenshot]

  def test_scrape_with_html_markdown_screenshot_formats_and_only_main_content_false
    vcr_cassette do
      options = Firecrawl::ScrapeOptions.build do
        formats [:html, :markdown, :screenshot]
        only_main_content false
      end

      response = scrape_request.submit( @url, options )

      assert_successful_response response
      result = response.result
      assert result.success?
      assert_match( /example domains/i, result.metadata[ 'title' ] )

      refute_nil result.html
      refute_nil result.markdown
      refute_nil result.screenshot_url
      assert_match( /number of domains such as example/i, result.html )
      assert_match( /about/i, result.html )
      assert_match( /number of domains such as example/i, result.markdown )
      assert_match( /about/i, result.markdown )

      assert_nil result.raw_html
      assert_equal [], result.links
      assert result.actions.empty?
      assert_nil result.warning
    end
  end

  def test_scrape_with_html_markdown_screenshot_formats_and_only_main_content_true
    vcr_cassette do
      options = Firecrawl::ScrapeOptions.build do
        formats [:html, :markdown, :screenshot]
        only_main_content true
      end

      response = scrape_request.submit( @url, options )

      assert_successful_response response
      result = response.result
      assert result.success?
      assert_match( /example domains/i, result.metadata[ 'title' ] )

      refute_nil result.html
      refute_nil result.markdown
      refute_nil result.screenshot_url
      assert_match( /number of domains such as example/i, result.html )
      refute_match( /about/i, result.html )
      assert_match( /number of domains such as example/i, result.markdown )
      refute_match( /about/i, result.markdown )

      assert_nil result.raw_html
      assert_equal [], result.links
      assert result.actions.empty?
      assert_nil result.warning
    end
  end

  # actions

  def test_scrape_with_wait_action
    vcr_cassette do
      options = Firecrawl::ScrapeOptions.build do
        formats [ :markdown ]
        action :wait do
          milliseconds 500
        end
      end

      response = scrape_request.submit( @url, options )

      assert_successful_response response
      result = response.result
      assert result.success?
      refute_nil result.markdown
    end
  end

  def test_scrape_with_screenshot_action
    vcr_cassette do
      options = Firecrawl::ScrapeOptions.build do
        formats [ :markdown ]
        action :wait do
          milliseconds 500
        end
        action :screenshot do
          full_page true
        end
      end

      response = scrape_request.submit( @url, options )

      assert_successful_response response
      result = response.result
      assert result.success?
      refute_nil result.markdown
      refute result.actions.empty?
      refute_nil result.actions.screenshots
      refute_empty result.actions.screenshots
    end
  end

  def test_scrape_with_multiple_actions
    vcr_cassette do
      options = Firecrawl::ScrapeOptions.build do
        formats [ :markdown ]
        action :wait do
          milliseconds 500
        end
        action :scroll do
          direction :down
        end
        action :screenshot do
          full_page false
        end
      end

      response = scrape_request.submit( @url, options )

      assert_successful_response response
      result = response.result
      assert result.success?
      refute_nil result.markdown
      refute result.actions.empty?
      refute_empty result.actions.screenshots
    end
  end

end
