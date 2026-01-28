module Firecrawl
  CrawlResultSchema = DynamicSchema::Struct.define do
    success             [ TrueClass, FalseClass ]
    id                  String
    status              Symbol
    total               Integer
    completed           Integer
    credits_used        Integer, as: :creditsUsed
    url                 String
    _value              :next, type: String
    expires_at          String, as: :expiresAt
    data                ScrapeResultData, array: true, default: []
  end

  class CrawlResult < CrawlResultSchema
    extend Forwardable

    STATUSES = [ :scraping, :completed, :failed, :cancelled ]

    def_delegators      :data,
                        :[], :[]=, :<<, :push, :pop, :shift, :unshift,
                        :length, :size, :empty?, :each

    def success?()      = self.success

    def crawling?()     = self.status == :scraping
    def completed?()    = self.status == :completed
    def failed?()       = self.status == :failed
    def cancelled?()    = self.status == :cancelled

    def status?( check_status )
      self.status == check_status
    end

    def next_url()      = self.next || self.url

    def merge_attributes( attributes )
      new_attributes = self.to_h.merge( attributes )
      data = attributes[ :data ]
      new_attributes[ :data ] = self.data.concat( data ) if data
      self.class.new( new_attributes )
    end
  end
end
