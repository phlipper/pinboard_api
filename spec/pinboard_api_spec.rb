require "spec_helper"

describe PinboardApi do
  before do
    @username = PinboardApi.username
    @password = PinboardApi.password

    PinboardApi.username = nil
    PinboardApi.password = nil
  end

  after do
    PinboardApi.username = @username
    PinboardApi.password = @password
  end

  it { PinboardApi.must_respond_to :username }
  it { PinboardApi.must_respond_to :password }

  it { PinboardApi.must_respond_to :api_version }
  it { PinboardApi.api_version.must_equal "v1" }

  it { PinboardApi.must_respond_to :adapter }
  it { PinboardApi.adapter.must_equal :net_http }

  it { PinboardApi.must_respond_to :ssl_options }
  it { PinboardApi.ssl_options.must_be_kind_of Hash }

  it { PinboardApi.must_respond_to :api_url }
  it { PinboardApi.api_url.must_equal "https://:@api.pinboard.in" }

  it { PinboardApi.must_respond_to :connection }
  it { PinboardApi.connection.must_be_kind_of Faraday::Connection }

  describe "credentials" do
    before do
      @username = PinboardApi.username
      @password = PinboardApi.password

      PinboardApi.username = "username"
      PinboardApi.password = "password"
    end

    after do
      PinboardApi.username = @username
      PinboardApi.password = @password
    end

    it { PinboardApi.username.must_equal "username" }
    it { PinboardApi.password.must_equal "password" }

    it "adds credentials to the api_url" do
      url = "https://username:password@api.pinboard.in"
      PinboardApi.api_url.must_equal url
    end
  end

  describe "ssl_options" do
    let(:ssl_test_options) do
      { ca_file: "/opt/local/share/curl/curl-ca-bundle.crt" }
    end

    before do
      @ssl_options = PinboardApi.ssl_options
      PinboardApi.ssl_options = ssl_test_options
    end

    after do
      PinboardApi.ssl_options = @ssl_options
      PinboardApi.password = @password
    end

    it { PinboardApi.ssl_options.must_equal ssl_test_options }
  end
end
