module Firecrawl
  class ErrorResult

    attr_reader :error_type, :error_description

    def initialize( status_code, attributes = nil )
      @error_type, @error_description = status_code_to_error( status_code )
      @error_description = attributes[ :error ] if attributes&.respond_to?( :[] ) && attributes[ :error ]
    end

  private
    def status_code_to_error( status_code )
      case status_code
      # this is here because I've noted invalid payloads being returned with a 200
      when 200
        [ :unexpected_error,
          "The response was successful but it did not include a valid payload." ]
      when 400
        [ :invalid_request_error,
          "There was an issue with the format or content of your request." ]
      when 401
        [ :authentication_error,
          "There's an issue with your API key." ]
      when 402
        [ :payment_required,
          "The request requires a paid account." ]
      when 404
        [ :not_found_error,
          "The requested resource was not found." ]
      when 429
        [ :rate_limit_error,
          "Your account has hit a rate limit." ]
      when 500..505
        [ :api_error,
          "An unexpected Firecrawl server error has occurred." ]
      when 529
        [ :overloaded_error,
          "The Firecrawl service is overloaded." ]
      else
        [ :unknown_error,
          "The Firecrawl service returned an unexpected status code: '#{status_code}'." ]
      end
    end
  end
end
