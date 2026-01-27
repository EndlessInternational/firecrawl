module Firecrawl

  ActionScrapeSchema = DynamicSchema::Struct.define do
    url                 String
    html                String
  end

  JavascriptReturnSchema = DynamicSchema::Struct.define do
    type                String
    value
  end

  ActionsResultSchema = DynamicSchema::Struct.define do
    screenshots         String, array: true
    scrapes             ActionScrapeSchema, array: true
    javascript_returns  JavascriptReturnSchema, array: true, as: :javascriptReturns
    pdfs                String, array: true
  end

  class ActionsResult < ActionsResultSchema
    def empty?
      ( screenshots.nil? || screenshots.empty? ) &&
      ( scrapes.nil? || scrapes.empty? ) &&
      ( javascript_returns.nil? || javascript_returns.empty? ) &&
      ( pdfs.nil? || pdfs.empty? )
    end
  end

  ChangeTrackingSchema = DynamicSchema::Struct.define do
    previous_scrape_at  String, as: :previousScrapeAt
    change_status       Symbol, as: :changeStatus
    visibility          Symbol
    diff                String
    json                Hash
  end

  class ChangeTracking < ChangeTrackingSchema
  end

  ScrapeResultDataSchema = DynamicSchema::Struct.define do
    metadata            Hash
    markdown            String
    summary             String
    html                String
    raw_html            String, as: :rawHtml
    screenshot_url      String, as: :screenshot
    links               String, array: true
    images              String, array: true
    actions             ActionsResult, default: ActionsResult.new( {} )
    extract             Hash
    warning             String
    change_tracking     ChangeTracking, as: :changeTracking
    branding            Hash
  end

  class ScrapeResultData < ScrapeResultDataSchema
    def metadata() = @metadata ||= _normalize_metadata( super )

  private

    def _normalize_metadata( metadata )
      return nil unless metadata
      metadata = metadata.transform_keys do | key |
        key.to_s.gsub( /([a-z])([A-Z])/, '\1_\2' ).downcase
      end
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
    def success?() = self.success
    def_delegators      :data,
                        :metadata, :warning,
                        :markdown, :summary, :html, :raw_html,
                        :screenshot_url, :links, :images, :actions,
                        :extract, :change_tracking, :branding
  end

end
