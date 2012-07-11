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
      if @time.is_a?(Time)
        @time
      elsif @time.is_a?(Date)
        @time.to_time
      else
        Time.parse(@time)
      end
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
      if posts.keys.include?("post")
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
  end
end
