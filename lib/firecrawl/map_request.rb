module Firecrawl
  class MapRequest < Request

    def submit( url, options = nil, &block )
      if options
        options = options.is_a?( MapOptions ) ? options : MapOptions.build( options.to_h )
        options = options.to_h
      else
        options = {}
      end
      options[ :url ] = url.to_s

      response = post( "#{BASE_URI}/map", options, &block )
      attributes = ( JSON.parse( response.body, symbolize_names: true ) rescue nil )

      result = if response.success?
        MapResult.new( attributes )
      else
        ErrorResult.new( response.status, attributes )
      end

      ResponseMethods.install( response, result )
    end

  end
end
