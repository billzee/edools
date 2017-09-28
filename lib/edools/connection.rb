require "net/http"
require "ostruct"
require "json"

class Connection
    ENDPOINT = "https://core.myedools.info"
    TOKEN = "e20c3d8a4c6f1c3da2a90704e87b6291:9a960117fe097dbf1d2eb8a5b30c3185"

    VERB_MAP = {
        :get    => Net::HTTP::Get,
        :post   => Net::HTTP::Post,
        :put    => Net::HTTP::Put
    }

    def initialize(endpoint = ENDPOINT)
        uri = URI.parse(endpoint)
        @http = Net::HTTP.new(uri.host, uri.port)
        @http.use_ssl = true
    end

    def get path
        request_json :get, path
    end

    def post path, params
        request_json :post, path, params
    end

    private

    def request_json method, path, params = {}
        response = request method, path, params
        body = JSON.parse(response.body)
        OpenStruct.new(:code => response.code, :body => body)
    rescue JSON::ParserError
        response
    end

    def request method, path, params = {}
        case method
        when :get
          full_path = encode_path_params(path, params)
          request = VERB_MAP[method].new(full_path)
        else
          request = VERB_MAP[method].new(path)
          request.set_form_data(params)
        end

        request["Authorization"] = "Token token=#{TOKEN}"
        @http.request(request)
    end

    def encode_path_params(path, params)
        encoded = URI.encode_www_form(params)
        [path, encoded].join("?")
    end
end
