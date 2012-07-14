PinboardApi.username = ENV["PINBOARD_USERNAME"]
PinboardApi.password = ENV["PINBOARD_PASSWORD"]
PinboardApi.auth_token = ENV["PINBOARD_AUTH_TOKEN"]

PinboardApi.ssl_options = ENV["PINBOARD_SSL_OPTIONS"] || begin
  if File.exists?("/opt/local/share/curl/curl-ca-bundle.crt")
    { ca_file: "/opt/local/share/curl/curl-ca-bundle.crt" }
  else
    { ca_path: "/System/Library/OpenSSL" }
  end
end
