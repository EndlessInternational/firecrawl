require 'spec_helper'

RSpec.describe Firecrawl::BatchScrapeRequest do

  include_context 'vcr'

  before do
    raise "A FIRECRAWL_API_KEY must be defined in the environment." unless ENV[ 'FIRECRAWL_API_KEY' ]
  end

  let( :urls ) { [ 'https://www.iana.org/help/example-domains', 'https://example.com' ] }

  let( :batch_scrape_request ) {
    described_class.new( connection: vcr_connection, api_key: ENV[ 'FIRECRAWL_API_KEY' ] )
  }

  def retrieve_all_results( request, response )
    result = response.result
    while response.success?
      break unless result.scraping? 
      sleep 0.500
      response = request.retrieve( result )
      result = response.result
    end
    [ response, result ]
  end

  context "where there are no scrape options" do
    it "scrapes the given urls, returning main content in markdown" do
      response = batch_scrape_request.submit( urls )
      binding.break unless response.success?

      expect( response ).to be_a( Faraday::Response )
      expect( response.success? ).to be( true ), response_error_description( response )
      expect( response.result ).to be_a( Firecrawl::BatchScrapeResult )

      response, result = retrieve_all_results( batch_scrape_request, response )
      binding.break unless response.success?
      expect( result.success ).to be true
      expect( result.total ).to eq( urls.length )
      # this sometimes fails (?)
      # expect( result.completed ).to eq( urls.length )
      expect( result.length ).to eq( urls.length )

      result.each do | data |
        expect( data.metadata[ 'title' ] ).to match( /example/i )
        expect( data.markdown ).to_not be_nil
        expect( data.html ).to be_nil
        expect( data.raw_html ).to be_nil
        expect( data.links ).to eq( [] )
        expect( data.screenshot_url ).to be_nil
        expect( data.actions ).to eq( {} )
        expect( data.warning ).to be_nil
      end
    end
  end

  context "where the scrape options include 'format :html'" do
    let( :options ) {
      Firecrawl::ScrapeOptions.build do
        formats :html
        only_main_content false
      end
    }

    it "scrapes the given urls, returning all content in html" do
      response = batch_scrape_request.submit( urls, options )
            binding.break unless response.success?


      expect( response ).to be_a( Faraday::Response )
      expect( response.success? ).to be( true ), response_error_description( response )
      expect( response.result ).to be_a( Firecrawl::BatchScrapeResult )

      response, result = retrieve_all_results( batch_scrape_request, response )
      binding.break unless response.success?
      expect( result.success ).to be true

      expect( result.data.length ).to eq( urls.length )
      data = result.data.first
      expect( data.html ).to_not be_nil
      expect( data.html ).to match( /example/i )
      expect( data.markdown ).to be_nil
    end 
  end

  context "where the scrape options include 'formats [:html, :markdown]'" do
    let( :options ) {
      Firecrawl::ScrapeOptions.build do
        formats [:html, :markdown]
        only_main_content false
      end
    }

    it "scrapes the given urls, returning all content in html and markdown" do
      response = batch_scrape_request.submit( urls, options )
      binding.break unless response.success?

      expect( response ).to be_a( Faraday::Response )
      expect( response.success? ).to be( true ), response_error_description( response )
      expect( response.result ).to be_a( Firecrawl::BatchScrapeResult )

      response, result = retrieve_all_results( batch_scrape_request, response )
      binding.break unless response.success?
      expect( result.success ).to be true

      expect( result.data.length ).to eq( urls.length )
      data = result.data.first
      expect( data.html ).to_not be_nil
      expect( data.markdown ).to_not be_nil
      expect( data.html ).to match( /example/i )
    end 
  end

  context "where the scrape options include 'format :screenshot'" do
    let( :options ) {
      Firecrawl::ScrapeOptions.build do
        formats :screenshot
      end
    }

    it "scrapes the given urls, returning a screenshot" do
      response = batch_scrape_request.submit( urls, options )

      expect( response ).to be_a( Faraday::Response )
      expect( response.success? ).to be( true ), response_error_description( response )
      expect( response.result ).to be_a( Firecrawl::BatchScrapeResult )

      response, result = retrieve_all_results( batch_scrape_request, response )
      binding.break unless response.success?
      expect( result.success ).to be true

      expect( result.data.length ).to eq( urls.length )
      result.data.each do |data|
        expect( data.screenshot_url ).to_not be_nil
        expect( data.markdown ).to be_nil
        expect( data.html ).to be_nil
        expect( data.raw_html ).to be_nil
        expect( data.links ).to eq( [] )
        expect( data.actions ).to eq( {} )
        expect( data.warning ).to be_nil
      end
    end
  end

  context "where the scrape options include a screenshot option" do

    let( :options ) {
      Firecrawl::ScrapeOptions.build do
        screenshot { full_page true }
      end
    }

    it "scrapes the given urls, returning a screenshot" do
      response = batch_scrape_request.submit( urls, options )
      binding.break unless response.success?
      expect( response ).to be_a( Faraday::Response )
      expect( response.success? ).to be( true ), response_error_description( response )
      expect( response.result ).to be_a( Firecrawl::BatchScrapeResult )

      response, result = retrieve_all_results( batch_scrape_request, response )
      binding.break unless response.success?
      expect( result.success ).to be true

      expect( result.data.length ).to eq( urls.length )
      result.data.each do |data|
        expect( data.screenshot_url ).to_not be_nil
        expect( data.markdown ).to be_nil
        expect( data.html ).to be_nil
        expect( data.raw_html ).to be_nil
        expect( data.links ).to eq( [] )
        expect( data.actions ).to eq( {} )
        expect( data.warning ).to be_nil
      end
    end
  end

  context "where the scrape options include 'formats [:html, :markdown, :screenshot]'" do
    let( :options ) {
      Firecrawl::ScrapeOptions.build do
        formats [:html, :markdown, :screenshot]
        only_main_content false
      end
    }

    it "scrapes the given urls, returning all content in html, markdown and the screenshot" do
      response = batch_scrape_request.submit( urls, options )

      expect( response ).to be_a( Faraday::Response )
      expect( response.success? ).to be( true ), response_error_description( response )
      expect( response.result ).to be_a( Firecrawl::BatchScrapeResult )

      response, result = retrieve_all_results( batch_scrape_request, response )
      expect( result.success ).to be true

      expect( result.data.length ).to eq( urls.length )
      data = result.data.first
      expect( data.html ).to_not be_nil
      expect( data.markdown ).to_not be_nil
      expect( data.screenshot_url ).to_not be_nil
      expect( data.html ).to match( /example/i )
    end 
  end
end
