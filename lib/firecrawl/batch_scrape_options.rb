module Firecrawl
  class BatchScrapeOptions
    include DynamicSchema::Definable
    include Helpers

    WEBHOOK_EVENTS = [ :completed, :page, :failed, :started ]

    schema do
      # reuse all scrape options
      instance_eval( &ScrapeOptions.schema )

      # batch-specific options
      max_concurrency       Integer, as: :maxConcurrency
      ignore_invalid_urls   [ TrueClass, FalseClass ], as: :ignoreInvalidURLs

      # batch-specific: webhook notifications
      webhook               do
        url                 String, required: true
        headers             Hash
        metadata            Hash
        events              Symbol, array: true, in: WEBHOOK_EVENTS
      end
    end

    def self.build( options = nil, &block )
      new( api_options: builder.build( options, &block ) )
    end

    def self.build!( options = nil, &block )
      new( api_options: builder.build!( options, &block ) )
    end

    def self.normalize_options( options )
      ScrapeOptions.normalize_options( options )
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