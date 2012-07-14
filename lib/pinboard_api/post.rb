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

    def save(options = {})
      validate!
      path = "/#{PinboardApi.api_version}/posts/add"
      params = {
        url:         @url,
        description: @description,
        extended:    @extended,
        tags:        Post.tag_param_string(tags),
        dt:          options[:dt],
        replace:     yes_no(options[:replace]),
        shared:      yes_no(options[:shared]),
        toread:      yes_no(options[:toread])
      }

      result = PinboardApi.request(path, params).body["result"]
      parse_result_code(result)
    end

    def destroy
      path = "/#{PinboardApi.api_version}/posts/delete"
      result = PinboardApi.request(path, url: @url).body["result"]
      parse_result_code(result)
    end

    def validate!
      if @url.blank?
        raise InvalidPostError, "url cannot be blank"
      end
      if @description.blank?
        raise InvalidPostError, "description cannot be blank"
      end
    end

    def yes_no(value)
      return nil if value.nil?
      value ? "yes" : "no"
    end

    def parse_result_code(result)
      unless result && code = result.fetch("code", false)
        raise InvalidResponseError, "unknown response"
      end

      code == "done" ? self : raise(InvalidResponseError, code.to_s)
    end

    def self.create(attributes)
      new(attributes).save
    end

    def self.destroy(url)
      if post = find(url: url).first
        post.destroy
      else
        raise InvalidResponseError, "unknown response"
      end
    end

    def self.all(options = {})
      path = "/#{PinboardApi.api_version}/posts/all"
      params = {
        tag:     tag_param_string(options[:tag]),
        start:   options[:start],
        results: options[:results],
        fromdt:  dt_param_string(options[:fromdt]),
        todt:    dt_param_string(options[:todt]),
        meta:    (options[:meta] ? 1 : 0)
      }

      response = PinboardApi.request(path, params)
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
      params = { tag: tag_param_string(options[:tag]), count: options[:count] }
      response = PinboardApi.request(path, params)
      extract_posts(response.body["posts"])
    end

    def self.dates(options = {})
      path = "/#{PinboardApi.api_version}/posts/dates"
      tag = tag_param_string(options[:tag])
      response = PinboardApi.request(path, tag: tag)

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
