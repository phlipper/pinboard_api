module PinboardApi
  class User

    def self.secret
      path = "/#{PinboardApi.api_version}/user/secret"
      PinboardApi.request(path).body["result"]
    end

  end
end
