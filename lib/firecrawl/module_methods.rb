module Firecrawl
  module ModuleMethods

    def connection( connection = nil )
      @connection = connection if connection
      @connection ||= Faraday.new { | builder | builder.adapter Faraday.default_adapter }
    end

    def api_key( api_key = nil )
      @api_key = api_key || @api_key
      @api_key 
    end  

    def scrape( url, options = nil, &block )
      Firecrawl::ScrapeRequest.new.submit( url, options, &block ) 
    end  
  end
end
