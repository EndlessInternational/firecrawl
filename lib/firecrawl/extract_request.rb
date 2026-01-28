module Firecrawl
  class ExtractRequest < Request

    def submit( urls, options = nil, &block )
      if options
        options = options.is_a?( ExtractOptions ) ? options : ExtractOptions.build( options.to_h )
        options = options.to_h

        scrape_options = options[ :scrapeOptions ]
        if scrape_options
          options[ :scrapeOptions ] = ScrapeOptions.normalize_options( scrape_options )
        end
      else
        options = {}
      end
      options[ :urls ] = [ urls ].flatten

      response = post( "#{BASE_URI}/extract", options, &block )
      attributes = ( JSON.parse( response.body, symbolize_names: true ) rescue nil )

      result = if response.success?
        ExtractResult.new( attributes )
      else
        ErrorResult.new( response.status, attributes )
      end

      ResponseMethods.install( response, result )
    end

    def retrieve( extract_result, &block )
      raise ArgumentError, "The first argument must be an instance of ExtractResult." \
        unless extract_result.is_a?( ExtractResult )

      url = extract_result.url || "#{BASE_URI}/extract/#{extract_result.id}"
      response = get( url, &block )
      attributes = ( JSON.parse( response.body, symbolize_names: true ) rescue nil )

      result = if response.success?
        extract_result.merge_attributes( attributes || { success: false, status: :failed } )
      else
        ErrorResult.new( response.status, attributes || {} )
      end

      ResponseMethods.install( response, result )
    end

  end
end
