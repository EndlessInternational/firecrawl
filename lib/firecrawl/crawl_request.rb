module Firecrawl 

  ##
  # The +CrawlRequest+ class encapsulates a crawl request to the Firecrawl API. After creating 
  # a new +CrawlRequest+ instance you can begin crawling by calling the +submit+ method and 
  # then subsequently retrieving the results by calling the +retrieve+ method.
  #
  # You can also optionally cancel the crawling operation by calling +cancel+.
  #
  # === examples
  # 
  # require 'firecrawl'
  #
  # request = Firecrawl::CrawlRequest.new( api_key: ENV[ 'FIRECRAWL_API_KEY' )
  #
  # urls = 'https://icann.org'
  # options = Firecrawl::CrawlOptions.build do 
  #   scrape_options        do 
  #     main_content_only   true 
  #   end 
  # end
  # 
  # crawl_response = request.submit( urls, options )
  # while crawl_response.success?
  #   crawl_result = crawl_response.result 
  #   if crawl_result.success?
  #     crawl_result.scrape_results.each do | result |
  #       puts response.metadata[ 'title ] 
  #       puts '---'
  #       puts response.markdown
  #       puts "\n\n"
  #     end
  #   end
  #   break unless crawl_result.status?( :scraping )
  #   crawl_response = request.retrieve( crawl_result )
  # end
  #
  # unless crawl_response.success? 
  #   puts crawl_response.result.error_description 
  # end 
  # 
  class CrawlRequest < Request 

    ## 
    # The +submit+ method makes a Firecrawl '/crawl' POST request which will initiate crawling 
    # of the given url. 
    # 
    # The response is always an instance of +Faraday::Response+. If +response.success?+ is true,
    # then +response.result+ will be an instance +CrawlResult+. If the request is not successful 
    # then +response.result+ will be an instance of +ErrorResult+.
    #
    # Remember that you should call +response.success?+ to validr that the call to the API was
    # successful and then +response.result.success?+ to validate that the API processed the
    # request successfuly. 
    #
    def submit( url, options = nil, &block )        
      if options
        options = options.is_a?( CrawlOptions ) ? options : CrawlOptions.build( options.to_h ) 
        options = options.to_h

        scrape_options = options[ :scrapeOptions ]
        if scrape_options 
          options[ :scrapeOptions ] = ScrapeOptions.normalize_options( scrape_options )
        end 
      else 
        options = {}
      end
      options[ :url ] = url
      response = post( "#{BASE_URI}/crawl", options, &block )
      result = nil 
      attributes = JSON.parse( response.body, symbolize_names: true ) rescue nil
      if response.success?
        result = CrawlResult.new( attributes )
      else 
        result = ErrorResult.new( response.status, attributes )
      end

      ResponseMethods.install( response, result )  
    end 

    ## 
    # The +retrieve+ method makes a Firecrawl '/crawl/{id}' GET request which will return the 
    # crawl results that were completed since the previous call to this method( or, if this is 
    # the first call to this method, since the crawl was started ). Note that there is no 
    # guarantee that there are any new crawl results at the time you make this call 
    # ( scrape_results may be empty ).
    # 
    # The response is always an instance of +Faraday::Response+. If +response.success?+ is 
    # +true+, then +response.result+ will be an instance +CrawlResult+. If the request is not 
    # successful then +response.result+ will be an instance of +ErrorResult+.
    #
    # Remember that you should call +response.success?+ to validate that the call to the API was
    # successful and then +response.result.success?+ to validate that the API processed the
    # request successfuly. 
    #
    def retrieve( crawl_result, &block )
      raise ArgumentError, "The first argument must be an instance of CrawlResult." \
        unless crawl_result.is_a?( CrawlResult )
      response = get( crawl_result.next_url, &block )  
      result = nil 
      attributes = JSON.parse( response.body, symbolize_names: true ) rescue nil
      if response.success? 
        result = crawl_result.merge_attributes( attributes || { success: false, status: :failed  } )
      else 
        result = ErrorResult.new( response.status, attributes || {} )
      end 

      ResponseMethods.install( response, result )     
    end

    ## 
    # The +cancel+ method makes a Firecrawl '/crawl/{id}' DELETE request which will cancel a 
    # previouslly submitted crawl.
    # 
    # The response is always an instance of +Faraday::Response+. If +response.success?+ is 
    # +true+, then +response.result+ will be an instance +CrawlResult+. If the request is not 
    # successful then +response.result+ will be an instance of +ErrorResult+.
    #
    # Remember that you should call +response.success?+ to validate that the call to the API was
    # successful and then +response.result.success?+ to validate that the API processed the
    # request successfuly. 
    #
    def cancel( crawl_result, &block )
      raise ArgumentError, "The first argument must be an instance of CrawlResult." \
        unless crawl_result.is_a?( CrawlResult )
      response = get( crawl_result.url, &block )  
      result = nil 
      attributes = JSON.parse( response.body, symbolize_names: true ) rescue nil
      if response.success? 
        result = crawl_result.merge_attributes( attributes || { success: false, status: :failed  } )
      else 
        result = ErrorResult.new( response.status, attributes || {} )
      end 

      ResponseMethods.install( response, result )     
    end

  end 
end
