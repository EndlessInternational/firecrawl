module Firecrawl
  class BatchScrapeOptions
    include DynamicSchema::Definable 
    include Helpers

    schema do 
      proxy                 Symbol, in: [ :basic, :stealth, :auto ] 
      skip_tls_verification [ TrueClass, FalseClass ], as: :skipTlsVerification
      mobile                [ TrueClass, FalseClass ]
      location              arguments: :country do  
        country             String, required: true # two digit country code
        languages           String, array: true #en-US jp etc
      end
      max_age               Integer, as: :maxAge
      headers               Hash

      only_main_content     [ TrueClass, FalseClass ], as: :onlyMainContent 
      include_tags          String, as: :includeTags, array: true 
      exclude_tags          String, as: :excludeTags, array: true 
      remove_base64_images  [ TrueClass, FalseClass ], as: :removeBase64Images
      block_ads             [ TrueClass, FalseClass ], as: :blockAds

      wait_for              Integer, as: :waitFor
      timeout               Integer 
      parsers               Symbol, array: true, in: [ :pdf ]

      formats               Symbol, in: ScrapeOptions::FORMATS, array: true
      screenshot            do 
        type                String, default: 'screenshot'
        full_page           [ TrueClass, FalseClass ], as: :fullPage 
        quality             Integer, in: 0..100
        viewport            do 
          height            Integer, required: true
          width             Integer, required: true 
        end
      end

      webhook               do 
        url                 URI, required: true 
        headers             Hash
        metadata            Hash 
        events              Symbol, array: true, in: [ :completed, :page, :failed, :started ]
      end 

      cache                 [ TrueClass, FalseClass ], as: :storeInCache
      zero_data_retention   [ TrueClass, FalseClass ], as: :zeroDataRetention
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