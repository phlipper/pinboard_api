require "faraday"
require "faraday_middleware"

require "core_ext/array"
require "core_ext/blank"
require "core_ext/hash"

require "pinboard_api/exceptions"
require "pinboard_api/request_utils"

require "pinboard_api/post"
require "pinboard_api/tag"
require "pinboard_api/user"
require "pinboard_api/version"

module PinboardApi

  class << self
    attr_accessor :username, :password, :auth_token, :adapter, :ssl_options
  end

  def self.adapter
    @adapter ||= :net_http
  end

  def self.ssl_options
    @ssl_options ||= {}
  end

  def self.api_version
    "v1"
  end

  def self.api_url
    "https://api.pinboard.in"
  end

  def self.connection
    Faraday.new(url: api_url, ssl: ssl_options) do |builder|
      builder.response :logger if ENV["PINBOARD_LOGGER"]
      builder.response :xml, content_type: /\bxml$/
      builder.basic_auth username, password if auth_token.blank?
      builder.adapter adapter
    end
  end

  def self.request(path, options = {}, &blk)
    options.merge!(auth_token: auth_token) unless auth_token.blank?
    PinboardApi.connection.get(path, options, &blk)
  end
end
