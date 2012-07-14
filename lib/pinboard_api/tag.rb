module PinboardApi
  class Tag
    attr_reader :name, :count

    def initialize(attributes = {})
      attributes.stringify_keys!

      @name  = attributes["name"] || attributes["tag"]
      @count = attributes["count"].to_i
    end

    def rename(new_name)
      path = "/#{PinboardApi.api_version}/tags/rename"
      response = PinboardApi.request(path) do |req|
        req.params["old"] = @name
        req.params["new"] = new_name.to_s
      end
      result = response.body["result"]

      if result == "done"
        Tag.new(name: new_name, count: @count)
      else
        raise InvalidResponseError, result.to_s
      end
    end

    def destroy
      path = "/#{PinboardApi.api_version}/tags/delete"
      result = PinboardApi.request(path, tag: @name).body["result"]

      if result == "done"
        self
      else
        raise InvalidResponseError, result.to_s
      end
    end

    def self.all
      path = "/#{PinboardApi.api_version}/tags/get"
      body = PinboardApi.request(path).body
      body["tags"]["tag"].map { |tag| new(tag) }
    rescue
      raise InvalidResponseError, "unknown response"
    end

    def self.find(name)
      all.detect { |t| t.name == name }
    end

    def self.destroy(tag)
      find(tag).destroy
    end
  end
end
