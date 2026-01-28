module Firecrawl
  class ScrapeRequest < Request

    def submit( url, options = nil, &block )
      if options
        options = options.is_a?( ScrapeOptions ) ? options : ScrapeOptions.build!( options.to_h )
        options = ScrapeOptions.normalize_options( options.to_h )
      else
        options = {}
      end
      options[ :url ] = url.to_s

      response = post( "#{BASE_URI}/scrape", options, &block )
      attributes = ( JSON.parse( response.body, symbolize_names: true ) rescue nil )

      result = if response.success?
        ScrapeResult.new( attributes )
      else
        ErrorResult.new( response.status, attributes )
      end

      ResponseMethods.install( response, result )
    end

  end
end
