module Firecrawl
  class ScrapeOptions
    include DynamicSchema::Definable
    include Helpers

    BASIC_FORMATS         = [ :summary, :markdown, :html, :raw_html, :links, :screenshot, :images,
                              :branding ]
    ACTIONS               = [ :wait, :click, :write, :press, :screenshot, :scrape, :scroll,
                              :execute_javascript, :pdf ]
    SCROLL_DIRECTIONS     = [ :up, :down ]
    PDF_FORMATS           = %w[ A0 A1 A2 A3 A4 A5 A6 Letter Legal Tabloid Ledger ]
    PDF_FORMAT_NORMALIZER = ->( v ) { v&.to_s&.capitalize }
    CHANGE_TRACKING_MODES = [ :'git-diff', :json ]

    schema do

      proxy             Symbol, in: [ :basic, :stealth, :auto ]
      skip_tls_verification [ TrueClass, FalseClass ], as: :skipTlsVerification
      mobile            [ TrueClass, FalseClass ]
      location          arguments: :country do
        country         String, required: true
        languages       String, array: true
      end
      max_age           Integer, as: :maxAge
      headers           Hash

      only_main_content [ TrueClass, FalseClass ], as: :onlyMainContent
      include_tags      String, as: :includeTags, array: true
      exclude_tags      String, as: :excludeTags, array: true
      remove_base64_images [ TrueClass, FalseClass ], as: :removeBase64Images
      block_ads         [ TrueClass, FalseClass ], as: :blockAds

      wait_for          Integer, as: :waitFor
      timeout           Integer

      parsers           as: :parsers, array: true do
        type            Symbol, required: true, in: [ :pdf ]
        max_pages       Integer, as: :maxPages, in: 1..10000
      end

      formats           Symbol, in: BASIC_FORMATS, array: true

      screenshot        do
        type            String, default: 'screenshot'
        full_page       [ TrueClass, FalseClass ], as: :fullPage
        quality         Integer, in: 0..100
        viewport        do
          height        Integer, required: true
          width         Integer, required: true
        end
      end

      json              do
        type            String, default: 'json'
        schema          Hash
        prompt          String
      end

      change_tracking   as: :changeTracking do
        type            String, default: 'changeTracking'
        modes           Symbol, array: true, in: CHANGE_TRACKING_MODES
        schema          Hash
        prompt          String
        tag             String
      end

      action            as: :actions, arguments: :type, array: true do
        type            Symbol, required: true, in: ACTIONS
        milliseconds    Integer
        selector        String
        all             [ TrueClass, FalseClass ]
        text            String
        key             String
        direction       Symbol, in: SCROLL_DIRECTIONS
        script          String
        full_page       [ TrueClass, FalseClass ], as: :fullPage
        quality         Integer, in: 0..100
        viewport        do
          width         Integer
          height        Integer
        end
        format          String, in: PDF_FORMATS, normalize: PDF_FORMAT_NORMALIZER
        landscape       [ TrueClass, FalseClass ]
        scale           [ Integer, Float ]
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
      formats = options[ :formats ] || []

      screenshot = options.delete( :screenshot )
      if screenshot
        formats.delete( :screenshot )
        formats << screenshot
      end

      json = options.delete( :json )
      formats << json if json

      change_tracking = options.delete( :changeTracking )
      formats << change_tracking if change_tracking

      options[ :formats ] = formats if formats.any?
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


