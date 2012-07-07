require "spec_helper"

describe PinboardApi::Post do
  it "is defined" do
    defined? PinboardApi::Post
  end

  let(:attributes) do
    {
      "description" => "Test Description",
      "extended" => "Test Extended",
      "hash" => "d58e3582afa99040e27b92b13c8f2280",
      "href" => "www.example.com",
      "tags" => "tag"
    }
  end

  let(:post) { PinboardApi::Post }
  let(:new_post) { PinboardApi::Post.new }

  it { new_post.must_respond_to :description }
  it { new_post.must_respond_to :extended }
  it { new_post.must_respond_to :hash }
  it { new_post.must_respond_to :href }
  it { new_post.must_respond_to :meta }
  it { new_post.must_respond_to :tags }
  it { new_post.must_respond_to :time }

  describe "#initialize" do
    let(:obj) { post.new(attributes) }

    it { obj.description.must_equal attributes["description"] }
    it { obj.extended.must_equal attributes["extended"] }
    it { obj.hash.must_equal attributes["hash"] }
    it { obj.href.must_equal attributes["href"] }
    it { obj.tags.must_equal Array(attributes["tags"]) }
    it { obj.time.must_be_kind_of Time }
  end

  describe "#time" do
    it { post.new("time" => Time.now).time.must_be_kind_of Time }
    it { post.new("time" => Date.new).time.must_be_kind_of Time }
    it { post.new("time" => "2013-01-01").time.must_be_kind_of Time }
  end

  describe "#tags" do
    it { post.new("tags" => "tag1").tags.must_equal ["tag1"] }
    it { post.new("tags" => "tag1 tag2").tags.must_equal ["tag1", "tag2"] }
    it { post.new("tags" => ["tag1", "tag2"]).tags.must_equal ["tag1", "tag2"] }
  end


  describe "self.find" do
    describe "found" do
      before do
        VCR.use_cassette("posts/find/found", preserve_exact_body_bytes: true) do
          @posts = PinboardApi::Post.find("tag" => "test")
        end
      end

      it { @posts.must_be_kind_of Array }
      it { @posts.wont_be_empty }
      it { @posts.first.href.wont_be_empty }
    end

    describe "not found" do
      before do
        VCR.use_cassette("posts/find/not_found") do
          @posts = PinboardApi::Post.find("tag" => "xxBOGUSxxINVALIDxx")
        end
      end

      it { @posts.must_be_empty }
    end
  end

  describe "self.update" do
    before do
      VCR.use_cassette("posts/update") do
        @last_update = PinboardApi::Post.update
      end
    end

    it { @last_update.must_be_kind_of Time }
  end
end
