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

  describe "self.suggest" do
    before do
      VCR.use_cassette("posts/suggest") do
        @suggestions = PinboardApi::Post.suggest("http://blog.com")
      end
    end

    it { @suggestions.must_be_kind_of Hash }
    it { @suggestions.keys.must_include "popular" }
    it { @suggestions["popular"].wont_be_empty }
    it { @suggestions.keys.must_include "recommended" }
    it { @suggestions["recommended"].wont_be_empty }
  end

  describe "self.recent" do
    describe "with default values" do
      before do
        VCR.use_cassette("posts/recent/default_values", preserve_exact_body_bytes: true) do
          @posts = PinboardApi::Post.recent
        end
      end

      it { @posts.must_be_kind_of Array }
      it { @posts.size.must_equal 15 }
      it { @posts.first.href.wont_be_empty }
    end

    describe "with custom count" do
      before do
        VCR.use_cassette("posts/recent/custom_count", preserve_exact_body_bytes: true) do
          @posts = PinboardApi::Post.recent(count: 3)
        end
      end

      it { @posts.must_be_kind_of Array }
      it { @posts.size.must_equal 3 }
      it { @posts.first.href.wont_be_empty }
    end

    describe "with custom tag" do
      before do
        VCR.use_cassette("posts/recent/custom_tags", preserve_exact_body_bytes: true) do
          @posts = PinboardApi::Post.recent(tag: %w[ruby programming])
        end
        @tags = @posts.map(&:tags).flatten
      end

      it { @posts.must_be_kind_of Array }
      it { @tags.must_include "ruby" }
      it { @tags.must_include "programming" }
    end
  end


  describe "self.tag_param_string" do
    before do
      @post = PinboardApi::Post
    end

    it { @post.tag_param_string(nil).must_be_nil }
    it { @post.tag_param_string("foo").must_equal "foo" }
    it { @post.tag_param_string("foo,bar").must_equal "foo,bar" }
    it { @post.tag_param_string(%w[foo bar]).must_equal "foo,bar" }
  end
end
