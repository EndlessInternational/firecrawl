require 'json'
require 'base64'
require 'uri'

require 'faraday'
require 'dynamic_schema'

require_relative 'firecrawl/version'

require_relative 'firecrawl/helpers'
require_relative 'firecrawl/error_result'
require_relative 'firecrawl/request'
require_relative 'firecrawl/response_methods'

require_relative 'firecrawl/scrape_options'
require_relative 'firecrawl/scrape_result'
require_relative 'firecrawl/scrape_request'
require_relative 'firecrawl/batch_scrape_result'
require_relative 'firecrawl/batch_scrape_options'
require_relative 'firecrawl/batch_scrape_request'
require_relative 'firecrawl/map_options'
require_relative 'firecrawl/map_result'
require_relative 'firecrawl/map_request'
require_relative 'firecrawl/crawl_options'
require_relative 'firecrawl/crawl_result'
require_relative 'firecrawl/crawl_request'
require_relative 'firecrawl/extract_options'
require_relative 'firecrawl/extract_result'
require_relative 'firecrawl/extract_request'

require_relative 'firecrawl/module_methods'

module Firecrawl
  extend ModuleMethods
end

