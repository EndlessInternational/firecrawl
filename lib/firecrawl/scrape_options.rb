module Firecrawl
  class ScrapeOptions 
    include DynamicSchema::Definable 
    include Helpers

    FORMATS = [ :summary, :markdown, :html, :raw_html, :links, :screenshot ]

    ACTIONS = [ :wait, :click, :write, :press, :screenshot, :scrape ]

    schema do 

      proxy             Symbol, in: [ :basic, :stealth, :auto ] 
      skip_tls_verification [ TrueClass, FalseClass ], as: :skipTlsVerification
      mobile            [ TrueClass, FalseClass ]
      location          arguments: :country do  
        country         String, required: true # two digit country code
        languages       String, array: true #en-US jp etc
      end
      max_age           Integer, as: :maxAge

      headers           Hash

      only_main_content [ TrueClass, FalseClass ], as: :onlyMainContent 
      include_tags      String, as: :includeTags, array: true 
      exclude_tags      String, as: :excludeTags, array: true 
      wait_for          Integer, as: :waitFor
      timeout           Integer 
      parsers           Symbol, array: true, in: [ :pdf ]

      formats           Symbol, in: FORMATS, array: true
      screenshot        do 
        type            String, default: 'screenshot'
        full_page       [ TrueClass, FalseClass ], as: :fullPage 
        quality         Integer, in: 0..100
        viewport        do 
          height        Integer, required: true
          width         Integer, required: true 
        end
      end


      action            as: :actions, arguments: :type, array: true do 
        type            Symbol, required: true, in: ACTIONS        
        # wait  
        milliseconds    Integer 
        # click 
        selector        String 
        # write 
        text            String 
        # press
        key             String 
      end 

      cache             [ TrueClass, FalseClass ], as: :storeInCache
      zero_retention    [ TrueClass, FalseClass ], as: :zeroDataRetention
    end

    def self.build( options = nil, &block )
      new( api_options: builder.build( options, &block ) )
    end 

    def self.build!( options = nil, &block )
      new( api_options: builder.build!( options, &block ) )
    end 

    def self.normalize_options( options )
      options = options&.dup || {}
      screenshot = options.delete( :screenshot )
      if screenshot
        formats = options[ :formats ] || []
        formats.delete( :screenshot )
        formats << screenshot 
        options[ :formats ] = formats
      end
      options 
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


