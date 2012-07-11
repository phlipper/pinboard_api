module PinboardApi
  class Post

    attr_reader :description, :extended, :hash, :href, :meta

    def initialize(attributes = {})
      @description = attributes["description"]
      @extended    = attributes["extended"]
      @hash        = attributes["hash"]
      @href        = attributes["href"]
      @meta        = attributes["meta"]
      @tags        = attributes["tags"] || attributes["tag"]
      @time        = attributes["time"] || Time.now
    end

    def time
      @time.is_a?(String) ? Time.parse(@time) : @time.to_time
    end

    def tags
      @tags.is_a?(String) ? @tags.split(/\s+/) : @tags
    end


    def self.find(options = {})
      path = "/#{PinboardApi.api_version}/posts/get"
      response = PinboardApi.connection.get(path) do |req|
        options.each_pair { |k,v| req.params[k.to_s] = v }
      end

      posts = response.body["posts"]
      if posts && posts.keys.include?("post")
        posts.inject([]) do |collection, tuple|
          key, attrs = tuple
          Array(collection) << new(attrs) if key == "post"
        end
      else
        Array.new
      end
    end

    def self.update
      path = "/#{PinboardApi.api_version}/posts/update"
      body = PinboardApi.connection.get(path).body
      Time.parse(body["update"]["time"])
    end

    def self.suggest(url)
      path = "/#{PinboardApi.api_version}/posts/suggest"
      response = PinboardApi.connection.get(path, url: url)
      response.body["suggested"]
    end

    def self.recent(options = {})
      path = "/#{PinboardApi.api_version}/posts/recent"
      tag = tag_param_string(options[:tag])
      count = options[:count]

      response = PinboardApi.connection.get(path) do |req|
        req.params["tag"] = tag if tag
        req.params["count"] = count if count
      end

      posts = response.body["posts"]["post"]
      posts.map { |attrs| new(attrs) }
    end

    def self.dates(options = {})
      path = "/#{PinboardApi.api_version}/posts/dates"
      tag = tag_param_string(options[:tag])

      response = PinboardApi.connection.get(path) do |req|
        req.params["tag"] = tag if tag
      end

      dates = response.body["dates"]["date"]
      dates.map do |date|
        date["count"] = date["count"].to_i
        date["date"]  = Date.parse(date["date"])
        date
      end
    end


    def self.tag_param_string(tags)
      tags.nil? ? nil : Array(tags).join(",")
    end
  end
end
