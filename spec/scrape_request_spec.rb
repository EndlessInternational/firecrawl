require 'spec_helper'

RSpec.describe Firecrawl::ScrapeRequest do

  include_context 'vcr'

  before do
    raise "A FIRECRAWL_API_KEY must be defined in the environment." unless ENV[ 'FIRECRAWL_API_KEY' ]
  end

  let ( :url ) {
    "https://www.iana.org/help/example-domains"
  }

  let ( :scrape_request ) {
    described_class.new( connection: vcr_connection, api_key: ENV[ 'FIRECRAWL_API_KEY' ] )
  }

  context "where there are no scrape options" do 
    it "scrapes the given url, returning main content in markdown" do 
      response = scrape_request.submit( url )

      expect( response ).to be_a( Faraday::Response )
      expect( response.success? ).to be( true ), response_error_description( response )     
      expect( response.result ).to be_a( Firecrawl::ScrapeResult )

      result = response.result 
      expect( result.success? ).to be true   
      expect( result.metadata[ 'title' ] ).to match( /example domains/i )
      # markdown is the default
      expect( result.markdown ).to_not be_nil
      expect( result.markdown ).to match( /number of domains such as example/ )
      # main content only is the default 
      expect( result.markdown ).not_to match( /about/i )

      expect( result.html ).to be_nil
      expect( result.raw_html ).to be_nil
      expect( result.links ).to eq( [] )
      expect( result.screenshot_url ).to be_nil
      expect( result.actions ).to eq( {} )
      expect( result.warning ).to be_nil
    end 
  end

  context "where the scrape options include 'only_main_content false'" do 

    let ( :options ) {
      Firecrawl::ScrapeOptions.build do 
        only_main_content false 
      end 
    }

    it "scrapes the given url returning all content in markdown" do 
      response = scrape_request.submit( url, options )

      expect( response ).to be_a( Faraday::Response )
      expect( response.success? ).to be( true ), response_error_description( response )     
      expect( response.result ).to be_a( Firecrawl::ScrapeResult )

      result = response.result 
      expect( result.success? ).to be true   
      expect( result.metadata[ 'title' ] ).to match( /example domains/i )
      # markdown is the default
      expect( result.markdown ).to_not be_nil
      expect( result.markdown ).to match( /number of domains such as example/i )
      expect( result.markdown ).to match( /about/i )

      expect( result.html ).to be_nil
      expect( result.raw_html ).to be_nil
      expect( result.links ).to eq( [] )
      expect( result.screenshot_url ).to be_nil
      expect( result.actions ).to eq( {} )
      expect( result.warning ).to be_nil
    end 
  end

  context "where the scrape options include 'only_main_content true'" do 

    let ( :options ) {
      Firecrawl::ScrapeOptions.build do 
        only_main_content true 
      end 
    }

    it "scrapes the given url, returning main content in markdown" do 
      response = scrape_request.submit( url )

      expect( response ).to be_a( Faraday::Response )
      expect( response.success? ).to be( true ), response_error_description( response )     
      expect( response.result ).to be_a( Firecrawl::ScrapeResult )

      result = response.result 
      expect( result.success? ).to be true   
      expect( result.metadata[ 'title' ] ).to match( /example domains/i )
      # markdown is the default
      expect( result.markdown ).to_not be_nil
      expect( result.markdown ).to match( /number of domains such as example/i )
      # main content only is the default 
      expect( result.markdown ).not_to match( /about/i )

      expect( result.html ).to be_nil
      expect( result.raw_html ).to be_nil
      expect( result.links ).to eq( [] )
      expect( result.screenshot_url ).to be_nil
      expect( result.actions ).to eq( {} )
      expect( result.warning ).to be_nil
    end 
  end

  context "where the scrape options include 'format :html'" do 
    context "where the scrape options include 'only_main_content false'" do 

      let ( :options ) {
        Firecrawl::ScrapeOptions.build do 
          formats :html
          only_main_content false 
        end 
      }

      it "scrapes the given url, returning all content in html" do 
        response = scrape_request.submit( url, options )

        expect( response ).to be_a( Faraday::Response )
        expect( response.success? ).to be( true ), response_error_description( response )     
        expect( response.result ).to be_a( Firecrawl::ScrapeResult )

        result = response.result 
        expect( result.success? ).to be true   
        expect( result.metadata[ 'title' ] ).to match( /example domains/i )
        expect( result.html ).to_not be_nil
        expect( result.html ).to match( /number of domains such as example/i )
        expect( result.html ).to match( /about/i )

        expect( result.markdown ).to be_nil
        # expect( result.html ).to be_nil
        expect( result.raw_html ).to be_nil
        expect( result.links ).to eq( [] )
        expect( result.screenshot_url ).to be_nil
        expect( result.actions ).to eq( {} )
        expect( result.warning ).to be_nil
      end 
    end

    context "where the scrape options include 'only_main_content true'" do 

      let ( :options ) {
        Firecrawl::ScrapeOptions.build do 
          formats :html
          only_main_content true 
        end 
      }

      it "scrapes the given url, returning main content in html" do 
        response = scrape_request.submit( url, options )

        expect( response ).to be_a( Faraday::Response )
        expect( response.success? ).to be( true ), response_error_description( response )     
        expect( response.result ).to be_a( Firecrawl::ScrapeResult )

        result = response.result 
        expect( result.success? ).to be true   
        expect( result.metadata[ 'title' ] ).to match( /example domains/i )
        expect( result.html ).to_not be_nil
        expect( result.html ).to match( /number of domains such as example/i )
        expect( result.html ).not_to match( /about/i )

        expect( result.markdown ).to be_nil
        # expect( result.html ).to be_nil
        expect( result.raw_html ).to be_nil
        expect( result.links ).to eq( [] )
        expect( result.screenshot_url ).to be_nil
        expect( result.actions ).to eq( {} )
        expect( result.warning ).to be_nil
      end 
    end

  end

  context "where the scrape options include 'formats [:html, :markdown]'" do 
    context "where the scrape options include 'only_main_content false'" do 

      let ( :options ) {
        Firecrawl::ScrapeOptions.build do 
          formats [:html, :markdown]
          only_main_content false 
        end 
      }

      it "scrapes the given url, returning all content in html and markdown" do 
        response = scrape_request.submit( url, options )

        expect( response ).to be_a( Faraday::Response )
        expect( response.success? ).to be( true ), response_error_description( response )     
        expect( response.result ).to be_a( Firecrawl::ScrapeResult )

        result = response.result 
        expect( result.success? ).to be true   
        expect( result.metadata[ 'title' ] ).to match( /example domains/i )
        expect( result.html ).to_not be_nil
        expect( result.markdown ).to_not be_nil
        expect( result.html ).to match( /number of domains such as example/i )
        expect( result.html ).to match( /about/i )
        expect( result.markdown ).to match( /number of domains such as example/i )
        expect( result.markdown ).to match( /about/i )
        
        # expect( result.markdown ).to be_nil
        # expect( result.html ).to be_nil
        expect( result.raw_html ).to be_nil
        expect( result.links ).to eq( [] )
        expect( result.screenshot_url ).to be_nil
        expect( result.actions ).to eq( {} )
        expect( result.warning ).to be_nil
      end 
    end

    context "where the scrape options include 'only_main_content true'" do 

      let ( :options ) {
        Firecrawl::ScrapeOptions.build do 
          formats [:html, :markdown]
          only_main_content true 
        end 
      }

      it "scrapes the given url, returning main content in html and markdown" do 
        response = scrape_request.submit( url, options )

        expect( response ).to be_a( Faraday::Response )
        expect( response.success? ).to be( true ), response_error_description( response )     
        expect( response.result ).to be_a( Firecrawl::ScrapeResult )

        result = response.result 
        expect( result.success? ).to be true   
        expect( result.metadata[ 'title' ] ).to match( /example domains/i )
        expect( result.html ).to_not be_nil
        expect( result.html ).to match( /number of domains such as example/i )
        expect( result.html ).not_to match( /about/i )
        expect( result.markdown ).to_not be_nil
        expect( result.markdown ).to match( /number of domains such as example/i )
        expect( result.markdown ).not_to match( /about/i )

        # expect( result.markdown ).to be_nil
        # expect( result.html ).to be_nil
        expect( result.raw_html ).to be_nil
        expect( result.links ).to eq( [] )
        expect( result.screenshot_url ).to be_nil
        expect( result.actions ).to eq( {} )
        expect( result.warning ).to be_nil
      end 
    end

  end

  context "where the scrape options include 'format :screenshot'" do 

    let ( :options ) {
      Firecrawl::ScrapeOptions.build do 
        formats :screenshot
      end 
    }

    it "scrapes the given url, returning a screenshot" do 
      response = scrape_request.submit( url, options )

      expect( response ).to be_a( Faraday::Response )
      expect( response.success? ).to be( true ), response_error_description( response )     
      expect( response.result ).to be_a( Firecrawl::ScrapeResult )

      result = response.result 
      expect( result.success? ).to be true   
      expect( result.metadata[ 'title' ] ).to match( /example domains/i )
      expect( result.screenshot_url ).to_not be_nil

      expect( result.markdown ).to be_nil
      expect( result.html ).to be_nil
      expect( result.raw_html ).to be_nil
      expect( result.links ).to eq( [] )
      # expect( result.screenshot_url ).to be_nil
      expect( result.actions ).to eq( {} )
      expect( result.warning ).to be_nil
    end

  end

  context "where the scrape options include a screenshot option" do 

    let ( :options ) {
      Firecrawl::ScrapeOptions.build do 
        screenshot { full_page true }
      end 
    }

    it "scrapes the given url, returning a screenshot" do 
      response = scrape_request.submit( url, options )

      expect( response ).to be_a( Faraday::Response )
      expect( response.success? ).to be( true ), response_error_description( response )     
      expect( response.result ).to be_a( Firecrawl::ScrapeResult )

      result = response.result 
      expect( result.success? ).to be true   
      expect( result.metadata[ 'title' ] ).to match( /example domains/i )
      expect( result.screenshot_url ).to_not be_nil

      expect( result.markdown ).to be_nil
      expect( result.html ).to be_nil
      expect( result.raw_html ).to be_nil
      expect( result.links ).to eq( [] )
      # expect( result.screenshot_url ).to be_nil
      expect( result.actions ).to eq( {} )
      expect( result.warning ).to be_nil
    end

  end

  context "where the scrape options include 'formats [:html, :markdown, :screenshot]'" do 
    context "where the scrape options include 'only_main_content false'" do 

      let ( :options ) {
        Firecrawl::ScrapeOptions.build do 
          formats [:html, :markdown, :screenshot]
          only_main_content false 
        end 
      }

      it "scrapes the given url, returning all content in html, markdown and the screenshot" do 
        response = scrape_request.submit( url, options )

        expect( response ).to be_a( Faraday::Response )
        expect( response.success? ).to be( true ), response_error_description( response )     
        expect( response.result ).to be_a( Firecrawl::ScrapeResult )

        result = response.result 
        expect( result.success? ).to be true   
        expect( result.metadata[ 'title' ] ).to match( /example domains/i )
        expect( result.html ).to_not be_nil
        expect( result.markdown ).to_not be_nil
        expect( result.html ).to match( /number of domains such as example/i )
        expect( result.html ).to match( /about/i )
        expect( result.markdown ).to match( /number of domains such as example/i )
        expect( result.markdown ).to match( /about/i )
        expect( result.screenshot_url ).to_not be_nil

        # expect( result.markdown ).to be_nil
        # expect( result.html ).to be_nil
        expect( result.raw_html ).to be_nil
        expect( result.links ).to eq( [] )
        # expect( result.screenshot_url ).to be_nil
        expect( result.actions ).to eq( {} )
        expect( result.warning ).to be_nil
      end 
    end

    context "where the scrape options include 'only_main_content true'" do 

      let ( :options ) {
        Firecrawl::ScrapeOptions.build do 
          formats [:html, :markdown, :screenshot]
          only_main_content true 
        end 
      }

      it "scrapes the given url, returning main content in html, markdown, and the screenshot" do 
        response = scrape_request.submit( url, options )

        expect( response ).to be_a( Faraday::Response )
        expect( response.success? ).to be( true ), response_error_description( response )      
        expect( response.result ).to be_a( Firecrawl::ScrapeResult )

        result = response.result 
        expect( result.success? ).to be( true )      
        expect( result.metadata[ 'title' ] ).to match( /example domains/i )
        expect( result.html ).to_not be_nil
        expect( result.html ).to match( /number of domains such as example/i )
        expect( result.html ).not_to match( /about/i )
        expect( result.markdown ).to_not be_nil
        expect( result.markdown ).to match( /number of domains such as example/i )
        expect( result.markdown ).not_to match( /about/i )
        expect( result.screenshot_url ).to_not be_nil

        # expect( result.markdown ).to be_nil
        # expect( result.html ).to be_nil
        expect( result.raw_html ).to be_nil
        expect( result.links ).to eq( [] )
        # expect( result.screenshot_url ).to be_nil
        expect( result.actions ).to eq( {} )
        expect( result.warning ).to be_nil
      end 
    end

  end
end 
