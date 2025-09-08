module Firecrawl 
  ##
  # The +MapRequest+ class encapsulates a '/map' POST request to the Firecrawl API. After creating
  # a new +MapRequest+ instance you can make the request by calling the +map+ method to crawl the 
  # site and retrieve +links+
  #
  # === examples
  # 
  # require 'firecrawl'
  #
  # request = Firecrawl::MapRequest.new( api_key: ENV[ 'FIRECRAWL_API_KEY' )
  #
  # response = request.submit( 'https://example.com', { limit: 100 } )
  # if response.success?
  #   result = response.result 
  #   if result.success? 
  #     result.links.each do | link |
  #       puts link 
  #     end 
  #   end 
  # else 
  #   puts response.result.error_description 
  # end 
  # 
  class MapRequest < Request 

    ## 
    # The +submit+ method makes a Firecrawl '/map' POST request which will scrape the site with 
    # given url and return links to all hosted pages related to that url. 
    # 
    # The response is always an instance of +Faraday::Response+. If +response.success?+ is true,
    # then +response.result+ will be an instance +MapResult+. If the request is not successful 
    # then +response.result+ will be an instance of +ErrorResult+.
    #
    def submit( url, options = nil, &block )    
      if options
        options = options.is_a?( MapOptions ) ? options : MapOptions.build( options.to_h ) 
        options = options.to_h
      else 
        options = {}
      end
      options[ :url ] = url.to_s     

      response = post( "#{BASE_URI}/map", options, &block )
      result = nil 
      if response.success?  
        attributes = ( JSON.parse( response.body, symbolize_names: true ) rescue nil )
        result = MapResult.new( attributes )
      else 
        result = ErrorResult.new( response.status, attributes ) 
      end
      
      ResponseMethods.install( response, result )     
    end 

  end 
end
