module Firecrawl
  class MapOptions
    include DynamicSchema::Definable 
    include DynamicSchema::Buildable 

    schema do 
      search                      String
      sitemap                     Symbol, in: [ :skip, :include ] 
      include_subdomains          [ TrueClass, FalseClass ], as: :includeSubdomains
      ignore_query_parameters     [ TrueClass, FalseClass ], as: :ignoreQueryParameters
      limit                       Integer, in: (0..)
      timeout                     Integer, in: (0..)
      location                    arguments: :country do  
        country                   String, required: true # two digit country code
        languages                 String, array: true #en-US jp etc
      end
    end

    def initialize( options = {}, api_options: nil )
      @options = self.class.builder.build( options || {} )
      @options = api_options.merge( @options ) if api_options 
    end

    def to_h()                    = @options.to_h

  end
end


