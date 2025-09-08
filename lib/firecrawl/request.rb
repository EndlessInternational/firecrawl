module Firecrawl 

  ##
  # The +Request+ class encapsulates a request to the Firecrawl API. After creating a new 
  # +Request+ instance you can make the actual request by calling the +scrape+, +begin_crawl+ 
  # +crawl+, +end_crawl+ or +map+ methods.
  #
  # === example
  # 
  # require 'firecrawl'
  #
  # request = Firecrawl::Request.new( api_key: ENV[ 'FIRECRAWL_API_KEY' )
  #
  # options = Firecrawl::ScrapeOptions.build do 
  #   format                [ :markdown, :screenshot ]
  #   only_main_content     true
  # end
  #
  # response = request.scrape( 'https://cnn.com', criteria )
  # if response.success?
  #   result = response.result 
  #   puts response.metadata[ :title ] 
  #   puts '---'
  #   puts response.markdown
  # else 
  #   puts response.result.error_description 
  # end 
  # 
  class Request 

    BASE_URI = 'https://api.firecrawl.dev/v2'

    ##
    # The +initialize+ method initializes the +Request+ instance. You MUST pass an +api_key+ and
    # and optionally a (Faraday) +connection+.
    #
    def initialize( connection: nil, api_key: nil )
      @connection = connection || Firecrawl.connection
      @api_key = api_key || Firecrawl.api_key
      raise ArgumentError, "An 'api_key' is required unless configured using 'Firecrawl.api_key'." \
        unless @api_key
    end

  protected

    def post( uri, body, &block )
      headers = { 
        'Authorization' => "Bearer #{@api_key}", 
        'Content-Type' => 'application/json'
      }   

      @connection.post( uri ) do | request |
        headers.each { | key, value | request.headers[ key ] = value }
        request.body = body.is_a?( String ) ? body : JSON.generate( body )  
        block.call( request ) if block 
      end
    end 

    def get( uri, &block )
      headers = { 
        'Authorization' => "Bearer #{@api_key}", 
        'Content-Type' => 'application/json'
      }   

      @connection.get( uri ) do | request |
        headers.each { | key, value | request.headers[ key ] = value }
        block.call( request ) if block 
      end
    end 

    def delete( uri, &block )
      headers = { 
        'Authorization' => "Bearer #{@api_key}", 
        'Content-Type' => 'application/json'
      }   

      @connection.delete( uri ) do | request |
        headers.each { | key, value | request.headers[ key ] = value }
        block.call( request ) if block 
      end
    end 

  end

end
