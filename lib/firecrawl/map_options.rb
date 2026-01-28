module Firecrawl
  class MapOptions
    include DynamicSchema::Definable
    include Helpers

    SITEMAP_MODES = [ :skip, :include, :only ]

    schema do
      search                      String
      sitemap                     Symbol, in: SITEMAP_MODES
      include_subdomains          [ TrueClass, FalseClass ], as: :includeSubdomains
      ignore_query_parameters     [ TrueClass, FalseClass ], as: :ignoreQueryParameters
      ignore_cache                [ TrueClass, FalseClass ], as: :ignoreCache
      limit                       Integer, in: 1..100000
      timeout                     Integer, in: ( 0.. )
      location                    arguments: :country do
        country                   String, required: true
        languages                 String, array: true
      end
    end

    def self.build( options = nil, &block )
      new( api_options: builder.build( options, &block ) )
    end

    def self.build!( options = nil, &block )
      new( api_options: builder.build!( options, &block ) )
    end

    def initialize( options = {}, api_options: nil )
      @options = self.class.builder.build( options || {} )
      @options = api_options.merge( @options ) if api_options
    end

    def to_h
      @options.to_h
    end

  end
end


