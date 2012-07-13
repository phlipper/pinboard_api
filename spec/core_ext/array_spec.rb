require "spec_helper"

describe Array do

  describe "self.wrap" do
    it { Array.wrap(nil).must_equal [] }
    it { Array.wrap("string").must_equal ["string"] }
    it { Array.wrap(["array"]).must_equal ["array"] }
  end

end
