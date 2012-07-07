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
        req.params["old"] = self.name
        req.params["new"] = new_name.to_s
      end
      body = response.body

      if body["result"] == "done"
        Tag.new("name" => new_name, "count" => self.count)
      else
        raise body["result"].to_s
      end
    end

    def delete
      path = "/#{PinboardApi.api_version}/tags/delete"
      response = PinboardApi.connection.get(path) do |req|
        req.params["tag"] = self.name
      end
      body = response.body

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
    end

    def self.find(name)
      all.detect { |t| t.name == name }
    end

  end
end
