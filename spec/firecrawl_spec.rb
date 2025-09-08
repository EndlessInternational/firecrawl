require 'spec_helper'

RSpec.describe Firecrawl do

  before do
    raise "A FIRECRAWL_API_KEY must be defined in the environment." unless ENV[ 'FIRECRAWL_API_KEY' ]
    Firecrawl.api_key ENV[ 'FIRECRAWL_API_KEY' ]

    Firecrawl.connection vcr_connection 
  end

  let ( :url ) {
    "https://www.iana.org/help/example-domains"
  }

  describe '.scrape' do

    include_context 'vcr'
    
    context "where there are no scrape options" do 
      it "scrapes the given url, returning main content in markdown" do 
        response = described_class.scrape( url )

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

    context "where the scrape options include options with 'format :html'" do 

      let ( :options ) {
        Firecrawl::ScrapeOptions.build do 
          formats :html
        end 
      }

      it "scrapes the given url, returning main content in html" do 
        response = described_class.scrape( url, options )

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
end 
