module Firecrawl
  class CrawlOptions
    include DynamicSchema::Definable
    include Helpers

    SITEMAP_MODES = [ :skip, :include, :only ]
    WEBHOOK_EVENTS = [ :completed, :page, :failed, :started ]

    schema do
      prompt                    String
      exclude_paths             String, as: :excludePaths, array: true
      include_paths             String, as: :includePaths, array: true
      maximum_depth             Integer, as: :maxDiscoveryDepth
      sitemap                   Symbol, in: SITEMAP_MODES
      limit                     Integer, in: ( 0.. )
      ignore_query_parameters   [ TrueClass, FalseClass ], as: :ignoreQueryParameters
      crawl_entire_domain       [ TrueClass, FalseClass ], as: :crawlEntireDomain
      allow_external_links      [ TrueClass, FalseClass ], as: :allowExternalLinks
      allow_subdomains          [ TrueClass, FalseClass ], as: :allowSubdomains
      delay                     [ Integer, Float ], in: ( 0.. )
      max_concurrency           Integer, in: ( 0.. ), as: :maxConcurrency

      webhook                   do
        url                     String, required: true
        headers                 Hash
        metadata                Hash
        events                  Symbol, array: true, in: WEBHOOK_EVENTS
      end

      scrape_options            as: :scrapeOptions, &ScrapeOptions.schema
      zero_data_retention       [ TrueClass, FalseClass ], as: :zeroDataRetention
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


