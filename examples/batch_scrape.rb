require_relative '../lib/firecrawl'
require 'debug'

request = Firecrawl::BatchScrapeRequest.new( api_key: ENV[ 'FIRECRAWL_API_KEY' ] )

options = Firecrawl::ScrapeOptions.build do 
  formats               [ :markdown, :screenshot ]
  only_main_content     true
end

urls = [ "https://example.org", "https://www.iana.org/help/example-domains", "https://www.firecrawl.dev" ]

response = request.submit( urls, options )
while response.success?
  batch_result = response.result 
  batch_result.each do | result |
    puts 'Title: ' + ( result.metadata[ 'title' ] || '' )
    puts 'URL: ' + ( result.metadata[ 'source_url' ] || '' )
    puts 'Screenshot: ' + result.screenshot_url
    puts '---'
    #puts result.markdown
    puts "\n\n"
  end 
  binding.break
  break unless batch_result.scraping? 
  sleep 0.500
  response = request.retrieve( batch_result )
end 

unless response.success?
  puts response.result.error_description 
end 



