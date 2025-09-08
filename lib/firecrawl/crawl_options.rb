module Firecrawl
  class CrawlOptions 
    include DynamicSchema::Definable 
    include Helpers

    schema do 
      exclude_paths         String, as: :excludePaths, array: true
      include_paths         String, as: :includePaths, array: true
      maximum_depth         Integer, as: :maxDiscoveryDepth 
      sitemap               Symbol, in: [ :skip, :include ] 
      limit                 Integer, in: (0..)
      ignore_query_parameters [ TrueClass, FalseClass ], as: :ignoreQueryParameters
      crawl_entire_domain   [ TrueClass, FalseClass ], as: :crawlEntireDomain
      allow_external_links  [ TrueClass, FalseClass ], as: :allowExternalLinks
      allow_subdomains      String, as: :allowSubdomains
      delay                 Integer, in: (0..)
      max_concurency        Integer, in: (0..), as: :maxConcurrency

      webhook               do 
        url                 URI, required: true 
        headers             Hash
        metadata            Hash 
        events              Symbol, array: true, in: [ :completed, :page, :failed, :started ]
      end 

      scrape_options        as: :scrapeOptions, &ScrapeOptions.schema
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


