module Firecrawl
  class Request

    BASE_URI = 'https://api.firecrawl.dev/v2'

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
