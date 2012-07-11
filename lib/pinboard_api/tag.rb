module PinboardApi
  class Tag
    attr_reader :name, :count

    def initialize(attributes = {})
      @name  = attributes["name"] || attributes["tag"]
      @count = attributes["count"].to_i
    end

    def rename(new_name)
      path = "/#{PinboardApi.api_version}/tags/rename"
      response = PinboardApi.connection.get(path) do |req|
        req.params["old"] = @name
        req.params["new"] = new_name.to_s
      end
      body = response.body

      if body["result"] == "done"
        Tag.new("name" => new_name, "count" => @count)
      else
        raise body["result"].to_s
      end
    end

    def destroy
      path = "/#{PinboardApi.api_version}/tags/delete"
      body = PinboardApi.connection.get(path, tag: @name).body

      if body["result"] == "done"
        self
      else
        raise body["result"].to_s
      end
    end

    def self.all
      path = "/#{PinboardApi.api_version}/tags/get"
      body = PinboardApi.connection.get(path).body
      body["tags"]["tag"].map { |tag| new(tag) }
    rescue
      raise RuntimeError, "unknown response"
    end

    def self.find(name)
      all.detect { |t| t.name == name }
    end

    def self.delete(tag)
      find(tag).destroy
    end
  end
end
