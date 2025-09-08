module Firecrawl 

  MapResultSchema = DynamicSchema::Struct.define do
    success             [ TrueClass, FalseClass ]
    links               array: true do 
      url               String 
      title             String 
      description       String 
    end              
  end

  class MapResult < MapResultSchema
    extend Forwardable
    def_delegators      :links,
                        :[], :[]=, :<<, :push, :pop, :shift, :unshift,
                        :length, :size, :empty?, :each
    def success?()      = success
  end

end

