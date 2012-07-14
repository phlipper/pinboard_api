require "spec_helper"

describe PinboardApi::RequestUtils do
  before do
    class Helper
      include PinboardApi::RequestUtils
    end
  end

  describe "yes_no" do
    it { Helper.new.yes_no(nil).must_be_nil }
    it { Helper.new.yes_no(true).must_equal "yes" }
    it { Helper.new.yes_no(false).must_equal "no" }
  end

  describe "self.dt_param_string" do
    let(:time) { Time.new(2012, 01, 01, 0, 0, 0, 0) }

    it { Helper.dt_param_string(nil).must_be_nil }
    it { Helper.dt_param_string(time).must_equal "2012-01-01T00:00:00Z" }
  end

  describe "self.tag_param_string" do
    it { Helper.tag_param_string(nil).must_be_nil }
    it { Helper.tag_param_string("foo").must_equal "foo" }
    it { Helper.tag_param_string("foo,bar").must_equal "foo,bar" }
    it { Helper.tag_param_string(%w[foo bar]).must_equal "foo,bar" }
  end
end
