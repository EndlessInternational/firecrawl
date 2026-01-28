module Firecrawl 
  module Helpers
    def string_camelize( string )
      words = string.split( /[\s_\-]/ )
      words.map.with_index { | word, index | index.zero? ? word.downcase : word.capitalize }.join
    end
  end
end
