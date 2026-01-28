module Firecrawl

  MapLinkSchema = DynamicSchema::Struct.define do
    url                 String
    title               String
    description         String
  end

  class MapLink < MapLinkSchema
  end

  MapResultSchema = DynamicSchema::Struct.define do
    success             [ TrueClass, FalseClass ]
    links               MapLink, array: true, default: []
  end

  class MapResult < MapResultSchema
    extend Forwardable

    def_delegators      :links,
                        :[], :[]=, :<<, :push, :pop, :shift, :unshift,
                        :length, :size, :empty?, :each

    def success?() = self.success
  end

end

