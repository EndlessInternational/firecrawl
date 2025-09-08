require_relative '../lib/firecrawl'

Firecrawl.api_key ENV[ 'FIRECRAWL_API_KEY' ]
response = Firecrawl.scrape(  
  ARGV[ 0 ] || 'https://example.com', 
  formats: [ :markdown, :screenshot ] 
)

if response.success?
  result = response.result 
  if result.success? 
    puts 'Title: ' + ( result.metadata[ 'title' ] || '' )
    puts 'Screenshot: ' + result.screenshot_url
    puts '---'
    puts result.metadata.to_h
    puts '---'
    puts result.markdown
  else  
    puts "The url '#{url}' could not be scraped."
  end
else 
  puts "Error: #{response.result.error_description}"
end 

