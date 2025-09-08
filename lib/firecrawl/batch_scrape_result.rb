module Firecrawl 

  BatchScrapeResultSchema = DynamicSchema::Struct.define do
    success             [ TrueClass, FalseClass ]
    id                  String
    invalid_urls        String, array: true

    total               Integer
    completed           Integer
    credits_used        Integer, as: :creditsUsed

    url                 String
    _value              :next, type: String
    
    expires_at          Date, as: :expiresAt
    data                ScrapeResultData, array: true, default: []
  end

  class BatchScrapeResult < BatchScrapeResultSchema
    extend Forwardable

    def_delegators      :data,
                        :[], :[]=, :<<, :push, :pop, :shift, :unshift,
                        :length, :size, :empty?, :each

    def scraping?()     = !!self.next_url
      
    def next_url()      = self.next || self.url 

    def merge_attributes( attributes )
      new_attributes = self.to_h.merge( attributes )
      data = attributes[ :data ]
      new_attributes[ :data ] = self.data.concat( data ) if data 
      self.class.new( attributes )
    end
  end

end
