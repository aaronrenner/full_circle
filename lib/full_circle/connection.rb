require "net/http"
module FullCircle
  class Connection

    attr_reader :domain, :cache

    # domain - domain of directory (ex. 360durango.com)
    # args
    #   - cache - Caching object to use
    def initialize(domain, cache: NullCache.new)
      @domain = domain
      @cache = cache
    end

    def base_uri
      "https://api.#{domain}/1.0/"
    end

    def call_api_method(method_name, query_params={})
      uri_str = uri_string(method_name, query_params)
      uri = URI(uri_str)

      body = cache.fetch(uri_str) do
        response_text = Net::HTTP.get(uri)
        cache.store(uri_str, response_text)
      end

      body
    end

    NullCache = Class.new do
      def fetch(key)
        yield
      end

      def store(key, value)
        value
      end
    end

    private

    attr_reader :response_class

    def uri_string(method_name, query_params)
      "#{base_uri}#{method_name}?#{query_params.to_query}"
    end
  end
end
