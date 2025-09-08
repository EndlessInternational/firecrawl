module Firecrawl 

  ScrapeResultDataSchema = DynamicSchema::Struct.define do
    metadata            Hash

    markdown            String
    html                String 
    raw_html            String,           as: :rawHtml

    screenshot_url      String,           as: :screenshot
    links               String,           array: true
    actions             Hash,             default: {}

    warning             String
  end

  class ScrapeResultData < ScrapeResultDataSchema 
    def metadata()        = @metadata ||= normalize_metadata( super )
  private
    def normalize_metadata( metadata )
      return nil unless metadata
      metadata = metadata.transform_keys do | key |
        key.to_s.gsub( /([a-z])([A-Z])/, '\1_\2' ).downcase
      end
      # remove the camelCase forms injected by Firecrawl
      metadata.delete_if do | key, _ | 
        key.start_with?( 'og_' ) && metadata.key?( key.sub( 'og_', 'og:' ) )
      end 
      metadata
    end
  end

  ScrapeResultSchema = DynamicSchema::Struct.define do
    success             [ TrueClass, FalseClass ]
    data                ScrapeResultData
  end

  class ScrapeResult < ScrapeResultSchema
    extend Forwardable
    def success?()      = self.success 
    def_delegators      :data,
                        :metadata, :warning,
                        :markdown, :html, :raw_html, 
                        :screenshot_url, :links, :actions

  end
end
