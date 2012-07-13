require "faraday"
require "faraday_middleware"

require "core_ext/array"
require "core_ext/hash"

require "pinboard_api/post"
require "pinboard_api/tag"
require "pinboard_api/user"
require "pinboard_api/version"

module PinboardApi

  class << self
    attr_accessor :username, :password, :adapter, :ssl_options

    def adapter
      @adapter ||= :net_http
    end

    def ssl_options
      @ssl_options ||= {}
    end

    def api_version
      "v1"
    end

    def api_url
      "https://#{username}:#{password}@api.pinboard.in"
    end

    def connection
      Faraday.new(url: api_url, ssl: ssl_options) do |builder|
        builder.response :logger if ENV["PINBOARD_LOGGER"]
        builder.response :xml, content_type: /\bxml$/
        builder.adapter adapter
      end
    end
  end

end
