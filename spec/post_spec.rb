require "spec_helper"

describe PinboardApi::Post do
  subject { PinboardApi::Post.new }

  it { subject.must_respond_to :description }
  it { subject.must_respond_to :extended }
  it { subject.must_respond_to :hash }
  it { subject.must_respond_to :url }
  it { subject.must_respond_to :meta }
  it { subject.must_respond_to :tags }
  it { subject.must_respond_to :time }


  let(:post) { PinboardApi::Post }
  let(:attributes) do
    {
      "description" => "Test Description",
      "extended"    => "Test Extended",
      "hash"        => "d58e3582afa99040e27b92b13c8f2280",
      "url"         => "www.example.com",
      "tags"        => "tag"
    }
  end


  # #######################
  # initialize
  # #######################
  describe "#initialize" do
    let(:obj) { post.new(attributes) }

    it { obj.description.must_equal attributes["description"] }
    it { obj.extended.must_equal attributes["extended"] }
    it { obj.hash.must_equal attributes["hash"] }
    it { obj.url.must_equal attributes["url"] }
    it { obj.tags.must_equal Array(attributes["tags"]) }
    it { obj.time.must_be_kind_of Time }
  end


  # #######################
  # time
  # #######################
  describe "#time" do
    it { post.new(time: Time.now).time.must_be_kind_of Time }
    it { post.new(time: Date.new).time.must_be_kind_of Time }
    it { post.new(time: "2013-01-01").time.must_be_kind_of Time }
  end


  # #######################
  # tags
  # #######################
  describe "#tags" do
    it { post.new(tags: "tag1").tags.must_equal ["tag1"] }
    it { post.new(tags: "tag1 tag2").tags.must_equal ["tag1", "tag2"] }
    it { post.new(tags: ["tag1", "tag2"]).tags.must_equal ["tag1", "tag2"] }
  end


  # #######################
  # save
  # #######################
  describe "#save" do
    describe "success" do
      let(:url) { "http://phlippers.net/pinboard_api" }
      let(:description) { "A Ruby client for the Pinboard.in API" }
      let(:extended) { "Extended Awesomeness" }
      let(:tags) { %w[ruby programming] }

      before do
        PinboardApi::VCR.use_cassette("posts/save") do
          post.destroy(url: url) rescue nil  # make sure it adds one
          params = {
            url: url, description: description, extended: extended, tags: tags
          }
          @post1 = post.new(params).save
          @post2 = post.find(url: url).first
        end
      end

      it { @post1.must_be_kind_of PinboardApi::Post }
      it { @post1.url.must_equal url }
      it { @post1.description.must_equal description }
      it { @post1.extended.must_equal extended }
      it { @post1.tags.must_equal tags }

      it { @post2.url.must_equal @post1.url }
      it { @post2.description.must_equal @post1.description }
      it { @post2.extended.must_equal @post1.extended }
      it { @post2.tags.must_equal @post1.tags }
    end

    describe "failure" do
      it { -> { post.new.save }.must_raise(PinboardApi::InvalidPostError) }
    end
  end


  # #######################
  # self.create
  # #######################
  describe "self.create" do
    describe "success" do
      let(:url) { "https://github.com/phlipper/pinboard_api" }
      let(:description) { "PinboardAPI on Github" }
      let(:extended) { "Extended Guthub Awesomeness" }
      let(:tags) { %w[pinboard github] }

      before do
        PinboardApi::VCR.use_cassette("posts/create") do
          post.destroy(url: url) rescue nil  # make sure it adds one
          params = {
            url: url, description: description, extended: extended, tags: tags
          }
          @post1 = post.create(params)
          @post2 = post.find(url: url).first
        end
      end

      it { @post1.must_be_kind_of PinboardApi::Post }
      it { @post1.url.must_equal url }
      it { @post1.description.must_equal description }
      it { @post1.extended.must_equal extended }
      it { @post1.tags.must_equal tags }

      it { @post2.url.must_equal @post1.url }
      it { @post2.description.must_equal @post1.description }
      it { @post2.extended.must_equal @post1.extended }
      it { @post2.tags.must_equal @post1.tags }
    end

    describe "failure" do
      it { -> { post.create({}) }.must_raise(PinboardApi::InvalidPostError) }
    end
  end


  # #######################
  # destroy
  # #######################
  describe "#destroy" do
    describe "when successful" do
      it "returns self" do
        PinboardApi::VCR.use_cassette("posts/destroy/successful_instance") do
          post = PinboardApi::Post.find(url: "http://duckduckgo.com/").first
          post.destroy.must_equal post
        end
      end
    end

    describe "when not successful" do
      it "raises an exception" do
        Faraday::Response.any_instance.stubs(:body).returns("")
        PinboardApi::VCR.use_cassette("posts/destroy/unsuccessful_instance") do
          post = PinboardApi::Post.new
          -> { post.destroy }.must_raise(PinboardApi::InvalidResponseError)
        end
      end
    end
  end


  # #######################
  # validate!
  # #######################
  describe "validate!" do
    let(:exception) { PinboardApi::InvalidPostError }

    it { -> { post.new.validate! }.must_raise(exception) }
    it { -> { post.new(url: "x").validate! }.must_raise(exception) }
  end


  # #######################
  # self.destroy
  # #######################
  describe "self.destroy" do
    describe "when successful" do
      it "returns self" do
        PinboardApi::VCR.use_cassette("posts/destroy/successful_class") do
          post = PinboardApi::Post.destroy("http://www.bing.com/")
          post.must_be_kind_of PinboardApi::Post
        end
      end
    end

    describe "when not successful" do
      it "raises an exception" do
        Faraday::Response.any_instance.stubs(:body).returns("")
        PinboardApi::VCR.use_cassette("posts/delete/unsuccessful_class") do
          -> {
            PinboardApi::Post.destroy("xxBOGUSxxINVALIDxx")
          }.must_raise(PinboardApi::InvalidResponseError)
        end
      end
    end
  end


  # #######################
  # self.all
  # #######################
  describe "self.all" do
    describe "found" do
      describe "with default values" do
        before do
          PinboardApi::VCR.use_cassette("posts/all/default_values") do
            @posts = PinboardApi::Post.all
          end
        end

        it { @posts.must_be_kind_of Array }
        it { @posts.first.must_be_kind_of PinboardApi::Post }
        it { @posts.first.url.wont_be_empty }
      end

      describe "with custom count" do
        before do
          PinboardApi::VCR.use_cassette("posts/all/custom_count") do
            @posts = PinboardApi::Post.all(results: 3)
          end
        end

        it { @posts.must_be_kind_of Array }
        it { @posts.size.must_equal 3 }
        it { @posts.first.url.wont_be_empty }
      end

      describe "with custom tag" do
        before do
          PinboardApi::VCR.use_cassette("posts/all/custom_tag") do
            @posts = PinboardApi::Post.all(tag: %w[ruby programming])
          end
          @tags = @posts.map(&:tags).flatten
        end

        it { @posts.must_be_kind_of Array }
        it { @tags.must_include "ruby" }
        it { @tags.must_include "programming" }
      end

      describe "with meta" do
        before do
          PinboardApi::VCR.use_cassette("posts/all/with_meta") do
            @posts = PinboardApi::Post.all(meta: true)
          end
        end

        it { @posts.must_be_kind_of Array }
        it { @posts.first.meta.wont_be_empty }
      end

      describe "with custom times" do
        let(:fromdt) { Time.gm(2012, 05, 01) }
        let(:todt)   { Time.gm(2012, 06, 01) }

        before do
          PinboardApi::VCR.use_cassette("posts/all/custom_times") do
            @posts = PinboardApi::Post.all(fromdt: fromdt, todt: todt)
          end
          @times = @posts.map(&:time).flatten
        end

        it { @times.min.must_be :>=, fromdt }
        it { @times.max.must_be :<=, todt }
      end
    end

    describe "not found" do
      before do
        PinboardApi::VCR.use_cassette("posts/all/not_found") do
          @posts = PinboardApi::Post.all(tag: "xxNOTxxFOUNDxx")
        end
      end

      it { @posts.must_be_empty }
    end
  end


  # #######################
  # self.find
  # #######################
  describe "self.find" do
    describe "found" do
      before do
        PinboardApi::VCR.use_cassette("posts/find/found") do
          @posts = PinboardApi::Post.find(tag: "test")
        end
      end

      it { @posts.must_be_kind_of Array }
      it { @posts.wont_be_empty }
      it { @posts.first.url.wont_be_empty }
    end

    describe "not found" do
      before do
        PinboardApi::VCR.use_cassette("posts/find/not_found") do
          @posts = PinboardApi::Post.find(tag: "xxBOGUSxxINVALIDxx")
        end
      end

      it { @posts.must_be_empty }
    end
  end


  # #######################
  # self.last_update
  # #######################
  describe "self.last_update" do
    before do
      PinboardApi::VCR.use_cassette("posts/update") do
        @last_update = PinboardApi::Post.last_update
      end
    end

    it { @last_update.must_be_kind_of Time }
  end


  # #######################
  # self.suggest
  # #######################
  describe "self.suggest" do
    before do
      PinboardApi::VCR.use_cassette("posts/suggest") do
        @suggestions = PinboardApi::Post.suggest("http://blog.com")
      end
    end

    it { @suggestions.must_be_kind_of Hash }
    it { @suggestions.keys.must_include "popular" }
    it { @suggestions["popular"].wont_be_empty }
    it { @suggestions.keys.must_include "recommended" }
    it { @suggestions["recommended"].wont_be_empty }
  end


  # #######################
  # self.recent
  # #######################
  describe "self.recent" do
    describe "with default values" do
      before do
        PinboardApi::VCR.use_cassette("posts/recent/default_values") do
          @posts = PinboardApi::Post.recent
        end
      end

      it { @posts.must_be_kind_of Array }
      it { @posts.size.must_equal 15 }
      it { @posts.first.url.wont_be_empty }
    end

    describe "with custom count" do
      before do
        PinboardApi::VCR.use_cassette("posts/recent/custom_count") do
          @posts = PinboardApi::Post.recent(count: 3)
        end
      end

      it { @posts.must_be_kind_of Array }
      it { @posts.size.must_equal 3 }
      it { @posts.first.url.wont_be_empty }
    end

    describe "with custom tag" do
      before do
        PinboardApi::VCR.use_cassette("posts/recent/custom_tag") do
          @posts = PinboardApi::Post.recent(tag: %w[ruby programming])
        end
        @tags = @posts.map(&:tags).flatten
      end

      it { @posts.must_be_kind_of Array }
      it { @tags.must_include "ruby" }
      it { @tags.must_include "programming" }
    end
  end


  # #######################
  # self.dates
  # #######################
  describe "self.dates" do
    describe "with default values" do
      before do
        PinboardApi::VCR.use_cassette("posts/dates/default_values") do
          @dates = PinboardApi::Post.dates
        end
        @date = @dates.first
      end

      it { @dates.must_be_kind_of Array }

      it { @date.keys.must_include "count" }
      it { @date.keys.must_include "date" }
      it { @date["count"].must_be_kind_of Fixnum }
      it { @date["date"].must_be_kind_of Date }
    end

    describe "with custom tag" do
      before do
        PinboardApi::VCR.use_cassette("posts/dates/custom_tag") do
          @all_dates = PinboardApi::Post.dates
          @tag_dates = PinboardApi::Post.dates(tag: "ruby")
        end
        @date = @tag_dates.first
      end

      it { @tag_dates.must_be_kind_of Array }
      it { @tag_dates.size.must_be :<, @all_dates.size }

      it { @date.keys.must_include "count" }
      it { @date.keys.must_include "date" }
      it { @date["count"].must_be_kind_of Fixnum }
      it { @date["date"].must_be_kind_of Date }
    end
  end


  # #######################
  # self.extract_posts
  # #######################
  describe "self.extract_posts" do
    describe "single post" do
      let(:payload) do
        {
          "user"=>"phlipper",
          "dt"=>"2012-07-11T05:52:58Z",
          "post"=> {
            "href"=>"http://www.baz.qux",
            "time"=>"2012-06-11T05:52:58Z",
            "description"=>"Baz Qux",
            "extended"=>"An extended Baz Qux",
            "tag"=>"protip baz qux",
            "hash"=>"472e1e39219178ac2ef7450c655d7f4b"
          }
        }
      end

      before do
        @posts = post.extract_posts(payload)
        @urls = @posts.map(&:url)
      end

      it { @posts.must_be_kind_of Array }
      it { @posts.wont_be_empty }
      it { @posts.first.must_be_kind_of PinboardApi::Post }

      it { @urls.must_include "http://www.baz.qux" }
    end

    describe "multiple posts" do
      let(:payload) do
        {
          "user"=>"phlipper",
          "dt"=>"2012-07-11T05:52:58Z",
          "post"=>[
            {
              "href"=>"http://www.foo.bar",
              "time"=>"2012-07-11T05:52:58Z",
              "description"=>"Foo Bar",
              "extended"=>"An extended Foo Bar",
              "tag"=>"protip foo bar",
              "hash"=>"927b1e39219178ac2ef7450c655d7f4b"
            },
            {
              "href"=>"http://www.baz.qux",
              "time"=>"2012-06-11T05:52:58Z",
              "description"=>"Baz Qux",
              "extended"=>"An extended Baz Qux",
              "tag"=>"protip baz qux",
              "hash"=>"472e1e39219178ac2ef7450c655d7f4b"
            }
          ]
        }
      end

      before do
        @posts = post.extract_posts(payload)
        @urls = @posts.map(&:url)
      end

      it { @posts.must_be_kind_of Array }
      it { @posts.wont_be_empty }
      it { @posts.first.must_be_kind_of PinboardApi::Post }

      it { @urls.must_include "http://www.foo.bar" }
      it { @urls.must_include "http://www.baz.qux" }
    end
  end
end
