module PinboardApi
  class User

    def self.secret
      path = "/#{PinboardApi.api_version}/user/secret"
      PinboardApi.connection.get(path).body["result"]
    end

  end
end
