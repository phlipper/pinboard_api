module PinboardApi
  class Post

    attr_reader :description, :extended, :hash, :meta, :url

    def initialize(attributes = {})
      attributes.stringify_keys!

      @description = attributes["description"]
      @extended    = attributes["extended"]
      @hash        = attributes["hash"]
      @meta        = attributes["meta"]
      @url         = attributes["url"] || attributes["href"]
      @tags        = attributes["tags"] || attributes["tag"]
      @time        = attributes["time"] || Time.now
    end

    def time
      @time.is_a?(String) ? Time.parse(@time) : @time.to_time
    end

    def tags
      @tags.is_a?(String) ? @tags.split(/\s+/) : @tags
    end

    def destroy
      path = "/#{PinboardApi.api_version}/posts/delete"
      body = PinboardApi.request(path, url: @url).body["result"]

      if body && body.fetch("code", "") == "done"
        self
      else
        raise RuntimeError, "unknown response"
      end
    end

    def self.destroy(url)
      if post = find(url: url).first
        post.destroy
      else
        raise RuntimeError, "unknown response"
      end
    end

    def self.all(options = {})
      path = "/#{PinboardApi.api_version}/posts/all"

      tag    = tag_param_string(options[:tag])
      fromdt = dt_param_string(options[:fromdt])
      todt   = dt_param_string(options[:todt])

      response = PinboardApi.request(path) do |req|
        req.params["tag"]     = tag if tag
        req.params["start"]   = options[:start] if options[:start]
        req.params["results"] = options[:results] if options[:results]
        req.params["fromdt"]  = fromdt if fromdt
        req.params["todt"]    = todt if todt
        req.params["meta"]    = 1 if options[:meta]
      end

      extract_posts(response.body["posts"])
    end

    def self.find(options = {})
      path = "/#{PinboardApi.api_version}/posts/get"
      response = PinboardApi.request(path) do |req|
        options.each_pair { |k,v| req.params[k.to_s] = v }
      end
      extract_posts(response.body["posts"])
    end

    def self.last_update
      path = "/#{PinboardApi.api_version}/posts/update"
      body = PinboardApi.request(path).body
      Time.parse(body["update"]["time"])
    end

    def self.suggest(url)
      path = "/#{PinboardApi.api_version}/posts/suggest"
      response = PinboardApi.request(path, url: url)
      response.body["suggested"]
    end

    def self.recent(options = {})
      path = "/#{PinboardApi.api_version}/posts/recent"
      tag = tag_param_string(options[:tag])
      count = options[:count]

      response = PinboardApi.request(path) do |req|
        req.params["tag"] = tag if tag
        req.params["count"] = count if count
      end

      extract_posts(response.body["posts"])
    end

    def self.dates(options = {})
      path = "/#{PinboardApi.api_version}/posts/dates"
      tag = tag_param_string(options[:tag])

      response = PinboardApi.request(path) do |req|
        req.params["tag"] = tag if tag
      end

      dates = response.body["dates"]["date"]
      dates.map do |date|
        { "count" => date["count"].to_i, "date" =>  Date.parse(date["date"]) }
      end
    end


    def self.extract_posts(payload)
      unless payload.respond_to?(:keys) && payload.keys.include?("post")
        return Array.new
      end

      # response.body["posts"] - "429 Too Many Requests.  Wait 60 seconds before fetching posts/all again."

      payload.inject([]) do |collection, (key, attrs)|
        if key == "post"
          Array.wrap(attrs).each do |post|
            Array.wrap(collection) << new(post)
          end
        end
        collection
      end
    end

    def self.dt_param_string(time)
      time.nil? ? nil : time.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
    end

    def self.tag_param_string(tags)
      tags.nil? ? nil : Array.wrap(tags).join(",")
    end
  end
end
