module Firecrawl

  ExtractSourceSchema = DynamicSchema::Struct.define do
    url                 String
    title               String
  end

  class ExtractSource < ExtractSourceSchema
  end

  ExtractResultSchema = DynamicSchema::Struct.define do
    success             [ TrueClass, FalseClass ]
    id                  String
    status              Symbol
    url                 String
    expires_at          String, as: :expiresAt
    tokens_used         Integer, as: :tokensUsed
    data                Hash, default: {}
    sources             ExtractSource, array: true, default: []
  end

  class ExtractResult < ExtractResultSchema
    extend Forwardable

    STATUSES = [ :processing, :completed, :failed, :cancelled ]

    def success?()      = self.success

    def processing?()   = self.status == :processing
    def completed?()    = self.status == :completed
    def failed?()       = self.status == :failed
    def cancelled?()    = self.status == :cancelled

    def status?( check_status )
      self.status == check_status
    end

    def merge_attributes( attributes )
      new_attributes = self.to_h.merge( attributes )
      self.class.new( new_attributes )
    end
  end

end
