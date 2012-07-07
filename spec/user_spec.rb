require "spec_helper"

describe PinboardApi::User do
  it "is defined" do
    defined? PinboardApi::User
  end

  describe "self.secret" do
    before do
      VCR.use_cassette("user/secret") do
        @secret = PinboardApi::User.secret
      end
    end

    it { @secret.wont_be :empty? }
    it { @secret.size.must_equal 20 }
    it { @secret.must_match /\w{20}/ }
  end
end
