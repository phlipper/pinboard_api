require "vcr"
require "base64"

VCR.configure do |c|
  c.default_cassette_options = { record: :once, serialize_with: :json }
  c.hook_into :faraday
  c.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  c.filter_sensitive_data("[USERNAME]") { PinboardApi.username }
  c.filter_sensitive_data("[PASSWORD]") { PinboardApi.password }
  c.filter_sensitive_data("[FILTERED]") do
    credentials = [PinboardApi.username, PinboardApi.password].join(":")
    Base64.encode64(credentials).chomp
  end
end
