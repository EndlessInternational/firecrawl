require_relative '../lib/firecrawl'
require 'debug'

request = Firecrawl::ScrapeRequest.new( api_key: ENV[ 'FIRECRAWL_API_KEY' ] )

options = Firecrawl::ScrapeOptions.build! do 
  formats               :markdown, :screenshot
  screenshot do 
    full_page           true 
  end
  only_main_content     true
end

response = request.submit( ARGV[ 0 ] || 'https://example.com', options )
if response.success?
  result = response.result 
  puts 'Title: ' + ( result.metadata[ 'title' ] || '' )
  puts 'Screenshot: ' + result.screenshot_url
  puts '---'
  puts result.metadata.to_h
  puts '---'
  puts result.markdown
else 
  puts response.result.error_description 
end 

