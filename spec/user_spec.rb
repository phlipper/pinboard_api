require "spec_helper"

describe PinboardApi::User do
  describe "self.secret" do
    before do
      PinboardApi::VCR.use_cassette("user/secret") do
        @secret = PinboardApi::User.secret
      end
    end

    it { @secret.wont_be :empty? }
    it { @secret.size.must_equal 20 }
    it { @secret.must_match /\w{20}/ }
  end
end
