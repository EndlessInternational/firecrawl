require_relative '../lib/firecrawl'

request = Firecrawl::MapRequest.new( api_key: ENV[ 'FIRECRAWL_API_KEY' ] )

options = Firecrawl::MapOptions.build do 
  limit           200
end

response = request.submit( ARGV[ 0 ] || "https://www.iana.org", options )
if response.success?
  result = response.result 
  if result.success? 
    result.each do | link |
      puts link.title
      puts link.url
    end 
  end 
else 
  puts response.result.error_description 
end 
