require "spec_helper"

describe PinboardApi::Tag do
  it "is defined" do
    defined? PinboardApi::Tag
  end

  let(:tag) { PinboardApi::Tag.new({"name" => "tag", "count" => 1}) }

  it { tag.must_respond_to :name }
  it { tag.name.must_equal "tag" }

  it { tag.must_respond_to :count }
  it { tag.count.must_equal 1 }


  describe "self.all" do
    before do
      VCR.use_cassette("tags/all") do
        @tags = PinboardApi::Tag.all
      end
    end

    it { @tags.wont_be :empty? }
    it { @tags.first.must_be_kind_of PinboardApi::Tag }
    it { @tags.first.name.wont_be :empty? }
    it { @tags.first.count.must_be :>=, 1 }
  end


  describe "self.find" do
    describe "found" do
      before do
        VCR.use_cassette("tags/find/found") do
          @tags = PinboardApi::Tag.all
          @tag  = PinboardApi::Tag.find(@tags.first.name)
        end
      end

      it { @tag.must_be_kind_of PinboardApi::Tag }
      it { @tag.name.must_equal @tags.first.name }
    end

    describe "not found" do
      before do
        VCR.use_cassette("tags/find/not_found") do
          @tag = PinboardApi::Tag.find("xxBOGUSxxINVALIDxx")
        end
      end

      it { @tag.must_be_nil }
    end
  end


  describe "#rename" do
    describe "when successful" do
      before do
        VCR.use_cassette("tags/rename/successful") do
          tag = PinboardApi::Tag.all.first
          @new_name = "z_#{tag.name}"
          @new_tag  = tag.rename(@new_name)
        end
      end

      it { @new_tag.name.must_equal @new_name }
    end

    describe "when rename fails" do
      it "raises an exception" do
        VCR.use_cassette("tags/rename/unsuccessful") do
          @tag = PinboardApi::Tag.all.first
          -> { @tag.rename("") }.must_raise(RuntimeError)
        end
      end
    end
  end


  describe "#destroy" do
    describe "when successful" do
      it "returns self when the remote tag has been destroyed" do
        VCR.use_cassette("tags/destroy/successful_instance") do
          tag = PinboardApi::Tag.find("junk")
          tag.destroy.must_equal tag
        end
      end

    end

    describe "when not successful" do
      it "raises an exception" do
        Faraday::Response.any_instance.stubs(:body).returns("")
        VCR.use_cassette("tags/destroy/unsuccessful_instance") do
          tag = PinboardApi::Tag.new("name" => "xxINVALIDxxBOGUSxx", "count" => 1)
          -> { tag.destroy }.must_raise(RuntimeError)
        end
      end
    end
  end

  describe "self.destroy" do
    describe "when successful" do
      it "returns self when the remote tag has been destroyed" do
        VCR.use_cassette("tags/destroy/successful_class") do
          tag = PinboardApi::Tag.destroy("junk")
          tag.must_be_kind_of PinboardApi::Tag
        end
      end
    end

    describe "when not successful" do
      it "raises an exception" do
        Faraday::Response.any_instance.stubs(:body).returns("")
        VCR.use_cassette("tags/destroy/unsuccessful_class") do
          -> { PinboardApi::Tag.destroy("xxINVALIDxxBOGUSxx") }.must_raise(RuntimeError)
        end
      end
    end
  end
end
