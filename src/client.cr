require "json"
require "http/client"
require "uri"
require "./search/search_request"
require "./search/search_response"

module Exa
  # Base error class for all Speechactors errors
  class Error < Exception; end

  # Raised when the API returns a 4xx error
  class ClientError < Error
    getter response : HTTP::Client::Response

    def initialize(@response)
      super("HTTP #{@response.status_code}: #{@response.body}")
    end
  end

  # Raised when the API returns a 5xx error
  class ServerError < Error
    getter response : HTTP::Client::Response

    def initialize(@response)
      super("HTTP #{@response.status_code}: #{@response.body}")
    end
  end

  # Raised when the API returns an unexpected content type
  class ContentTypeError < Error; end

  # Raised when the API key is invalid or missing
  class AuthenticationError < ClientError; end

  # Main client class
  class Client
    BASE_URL = "https://api.exa.ai"

    property api_key : String

    def initialize(api_key : String)
      @api_key = api_key
    end

    # Get all available voices
    # Returns an Array of Voice objects.
    def search(request : SearchRequest) : SearchResponse
      response = request("POST", "/search", request.to_json)

      handle_response(response) do
        if response.content_type != "application/json"
          raise ContentTypeError.new("Voices response has unexpected content type: #{response.content_type}")
        end

        #json = JSON.parse(response.body)

        SearchResponse.new JSON::PullParser.new(response.body)
      end
    end

    # 200	OK
    # 400	Bad Request
    # 401	Unauthorized
    # 404	Not found
    # 500	Internal Server Error
    private def handle_response(response : HTTP::Client::Response)
      case response.status_code
      when 200..299
        yield
      when 401, 403
        raise AuthenticationError.new(response)
      when 400..499
        raise ClientError.new(response)
      when 500..599
        raise ServerError.new(response)
      else
        raise Error.new("Unexpected response status: #{response.status_code}")
      end
    end

    # Send a request to the Exa API on a given http verb + endpoint with an optional body and query parameters
    private def request(method : String, endpoint : String, body : String? = nil, query_params : Hash(String, String)? = nil)
      method = method.upcase

      # build the headers
      headers = HTTP::Headers.new
      headers["x-api-key"] = @api_key
      headers["Content-Type"] = "application/json"
      
      # build the URL with query parameters
      uri = URI.parse("#{BASE_URL}#{endpoint}")
      if query_params && !query_params.empty?
        uri.query = URI::Params.encode(query_params)
      end

      HTTP::Client.new(uri) do |client|
        client.exec(method, uri.request_target, headers: headers, body: body)
      end
    end

    # Overload for block-based requests
    private def request(method : String, endpoint : String, body : String? = nil, query_params : Hash(String, String)? = nil, &block : HTTP::Client::Response -> _)
      method = method.upcase

      # build the headers
      headers = HTTP::Headers.new
      headers["x-api-key"] = @api_key
      headers["Content-Type"] = "application/json"
      
      # build the URL with query parameters
      uri = URI.parse("#{BASE_URL}#{endpoint}")
      if query_params && !query_params.empty?
        uri.query = URI::Params.encode(query_params)
      end

      HTTP::Client.exec(method, uri, headers: headers, body: body) do |response|
        yield response
      end
    end

    # Helper method to filter out nil values from query params
    private def filter_query_params(**params) : Hash(String, String)?
      # Convert NamedTuple to Hash and filter out nil values
      filtered = params.to_h.reject { |_, v| v.nil? }
      # Convert remaining values to strings and keys to strings
      string_hash = {} of String => String
      filtered.each do |k, v|
        string_hash[k.to_s] = v.to_s
      end
      string_hash.empty? ? nil : string_hash
    end
  end
end