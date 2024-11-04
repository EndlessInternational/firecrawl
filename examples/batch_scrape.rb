require_relative '../lib/firecrawl'
require 'debug'

request = Firecrawl::BatchScrapeRequest.new( api_key: ENV[ 'FIRECRAWL_API_KEY' ] )

options = Firecrawl::ScrapeOptions.build do 
  format                [ :markdown, 'screenshot@full_page' ]
  only_main_content     true
end

urls = [ "https://example.org", "https://www.iana.org/help/example-domains", "https://www.firecrawl.dev" ]

response = request.start_scraping( urls, options )
while response.success?
  batch_result = response.result 
  batch_result.scrape_results.each do | result |
    puts 'Title: ' + ( result.metadata[ 'title' ] || '' )
    puts 'Screenshot: ' + result.screenshot_url
    puts '---'
    puts result.markdown
    puts "\n\n"
  end 
  break unless batch_result.status?( :scraping ) 
  sleep 0.250
  response = request.retrieve_scraping( batch_result )
end 

unless response.success?
  puts response.result.error_description 
end 



