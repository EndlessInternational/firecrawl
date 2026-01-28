module Firecrawl
  class ExtractOptions
    include DynamicSchema::Definable
    include Helpers

    schema do
      prompt                    String
      schema                    Hash
      enable_web_search         [ TrueClass, FalseClass ], as: :enableWebSearch
      ignore_sitemap            [ TrueClass, FalseClass ], as: :ignoreSitemap
      include_subdomains        [ TrueClass, FalseClass ], as: :includeSubdomains
      show_sources              [ TrueClass, FalseClass ], as: :showSources
      ignore_invalid_urls       [ TrueClass, FalseClass ], as: :ignoreInvalidURLs

      scrape_options            as: :scrapeOptions, &ScrapeOptions.schema
    end

    def self.build( options = nil, &block )
      new( api_options: builder.build( options, &block ) )
    end

    def self.build!( options = nil, &block )
      new( api_options: builder.build!( options, &block ) )
    end

    def initialize( options = nil, api_options: nil )
      @options = self.class.builder.build( options || {} )
      @options = api_options.merge( @options ) if api_options
    end

    def to_h
      @options.to_h
    end

  end
end
