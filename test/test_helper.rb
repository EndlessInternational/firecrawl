require 'bundler/setup'
require 'minitest/autorun'
require 'debug'
require 'vcr'
require 'firecrawl'

SENSITIVE_URL_PARAMETERS = %w(
  key
)

SENSITIVE_REQUEST_HEADERS = %w(
  x-api-key
)

SENSITIVE_RESPONSE_HEADERS = %w(
  set-cookie Set-Cookie cf-ray request-id x-request-id x-cloud-trace-context
  openai-organization
)

VCR.configure do | config |
  config.cassette_library_dir = File.join( __dir__, 'fixtures', 'cassettes' )
  config.hook_into :faraday
  config.allow_http_connections_when_no_cassette = true

  config.filter_sensitive_data( '<TOKEN>' ) do | interaction |
    authorization = interaction.request.headers[ 'Authorization' ]&.first
    if authorization && match = authorization.match( /^Bearer\s+([^,\s]+)/ )
      match.captures.first
    end
  end

  config.before_record do | interaction |
    SENSITIVE_URL_PARAMETERS.each do | key |
      interaction.request.uri.gsub!( /(#{key}=)[^&]+/, "\\1<#{key.upcase}>" )
    end
    SENSITIVE_REQUEST_HEADERS.each do | header |
      interaction.request.headers[ header ]&.map! { "<#{header.upcase}>" }
    end
    SENSITIVE_RESPONSE_HEADERS.each do | header |
      interaction.response.headers[ header ]&.map! { "<#{header.upcase}>" }
    end
  end
end

CASSETTE_OPTIONS = {
  serialize_with: :json,
  match_requests_on: [
    :method,
    VCR.request_matchers.uri_without_params( *SENSITIVE_URL_PARAMETERS )
  ]
}

# Environment variable controls:
#   VCR=off      - ignore cassettes, make live requests
#   VCR=record   - record new cassettes (overwrite existing)
VCR_MODE = ENV.fetch( 'VCR', 'on' )

class Minitest::Test

  def vcr_cassette( name = nil, options = {}, &block )
    if VCR_MODE == 'off'
      VCR.turned_off( ignore_cassettes: true, &block )
    else
      name ||= "#{self.class.name}_#{self.name}"
      options = CASSETTE_OPTIONS.merge( options )
      options[ :record ] = :all if VCR_MODE == 'record'
      VCR.use_cassette( name, options, &block )
    end
  end

  def assert_successful_response( response )
    assert response.success?,
      "Expected successful response but got: #{response.result.error_description rescue response.status}"
  end

end
