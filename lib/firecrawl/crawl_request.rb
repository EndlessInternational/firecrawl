module Firecrawl
  class CrawlRequest < Request

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
      attributes = ( JSON.parse( response.body, symbolize_names: true ) rescue nil )

      result = if response.success?
        CrawlResult.new( attributes )
      else
        ErrorResult.new( response.status, attributes )
      end

      ResponseMethods.install( response, result )
    end

    def retrieve( crawl_result, &block )
      raise ArgumentError, "The first argument must be an instance of CrawlResult." \
        unless crawl_result.is_a?( CrawlResult )

      response = get( crawl_result.next_url, &block )
      attributes = ( JSON.parse( response.body, symbolize_names: true ) rescue nil )

      result = if response.success?
        crawl_result.merge_attributes( attributes || { success: false, status: :failed } )
      else
        ErrorResult.new( response.status, attributes || {} )
      end

      ResponseMethods.install( response, result )
    end

    def cancel( crawl_result, &block )
      raise ArgumentError, "The first argument must be an instance of CrawlResult." \
        unless crawl_result.is_a?( CrawlResult )

      response = delete( crawl_result.url, &block )
      attributes = ( JSON.parse( response.body, symbolize_names: true ) rescue nil )

      result = if response.success?
        crawl_result.merge_attributes( attributes || { success: false, status: :cancelled } )
      else
        ErrorResult.new( response.status, attributes || {} )
      end

      ResponseMethods.install( response, result )
    end

  end
end
