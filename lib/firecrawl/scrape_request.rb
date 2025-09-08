module Firecrawl 
  ##
  # The +ScrapeRequest+ class encapsulates a '/scrape' POST request to the Firecrawl API. After 
  # creating a new +ScrapeRequest+ instance you can initiate the request by calling the +submit+ 
  # method to perform synchronous scraping.  
  #
  # === examples
  # 
  # require 'firecrawl'
  #
  # request = Firecrawl::ScrapeRequest.new( api_key: ENV[ 'FIRECRAWL_API_KEY' )
  #
  # options = Firecrawl::ScrapeOptions.build do 
  #   format                [ :markdown, 'screenshot@full_page' ]
  #   only_main_content     true
  # end
  #
  # response = request.submit( 'https://example.com', options )
  # if response.success?
  #   result = response.result 
  #   puts response.metadata[ 'title ] 
  #   puts '---'
  #   puts response.markdown
  # else 
  #   puts response.result.error_description 
  # end 
  # 
  class ScrapeRequest < Request 

    ## 
    # The +submit+ method makes a Firecrawl '/scrape' POST request which will scrape the given url. 
    # 
    # The response is always an instance of +Faraday::Response+. If +response.success?+ is true,
    # then +response.result+ will be an instance +ScrapeResult+. If the request is not successful 
    # then +response.result+ will be an instance of +ErrorResult+.
    #
    def submit( url, options = nil, &block )    
      if options
        options = options.is_a?( ScrapeOptions ) ? options : ScrapeOptions.build!( options.to_h ) 
        options = ScrapeOptions.normalize_options( options.to_h )
      else 
        options = {}
      end
      options[ :url ] = url.to_s

      response = post( "#{BASE_URI}/scrape", options, &block )
      result = nil 
      if response.success?  
        attributes = ( JSON.parse( response.body, symbolize_names: true ) rescue nil )
        result = ScrapeResult.new( attributes )
      else 
        result = ErrorResult.new( response.status, attributes )
      end
      
      ResponseMethods.install( response, result )     
    end 

  private 

  end 
end
