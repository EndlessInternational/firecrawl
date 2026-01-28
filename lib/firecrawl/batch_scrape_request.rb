module Firecrawl
  class BatchScrapeRequest < Request

    def submit( urls, options = nil, &block )
      if options
        options = options.is_a?( BatchScrapeOptions ) ? options : BatchScrapeOptions.build( options.to_h )
        options = BatchScrapeOptions.normalize_options( options.to_h )
      else
        options = {}
      end
      options[ :urls ] = [ urls ].flatten

      response = post( "#{BASE_URI}/batch/scrape", options, &block )
      attributes = ( JSON.parse( response.body, symbolize_names: true ) rescue nil )

      result = if response.success?
        BatchScrapeResult.new( attributes )
      else
        ErrorResult.new( response.status, attributes || {} )
      end

      ResponseMethods.install( response, result )
    end

    def retrieve( batch_result, &block )
      raise ArgumentError, "The first argument must be an instance of BatchScrapeResult." \
        unless batch_result.is_a?( BatchScrapeResult )

      response = get( batch_result.next_url, &block )
      attributes = ( JSON.parse( response.body, symbolize_names: true ) rescue nil )

      result = if response.success?
        attributes ||= { success: false, status: :failed }
        batch_result.merge_attributes( attributes )
      else
        ErrorResult.new( response.status, attributes || {} )
      end

      ResponseMethods.install( response, result )
    end

    def retrieve_all( batch_result, &block )
      raise ArgumentError, "The first argument must be an instance of BatchScrapeResult." \
        unless batch_result.is_a?( BatchScrapeResult )

      response = get( batch_result.url, &block )
      attributes = ( JSON.parse( response.body, symbolize_names: true ) rescue nil )

      result = if response.success?
        attributes ||= { success: false, status: :failed }
        # the next url should not be set by this method so that retrieve and retrieve_all
        # do not impact each other
        attributes.delete( :next )
        batch_result.merge_attributes( attributes )
      else
        ErrorResult.new( response.status, attributes || {} )
      end

      ResponseMethods.install( response, result )
    end

  end
end
