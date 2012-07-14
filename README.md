# PinboardApi [![Build Status](https://secure.travis-ci.org/phlipper/pinboard_api.png?branch=master)](http://travis-ci.org/phlipper/pinboard_api) [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/phlipper/pinboard_api)

## Description

A Ruby API client for [Pinboard.in](https://pinboard.in/), the bookmarking website for introverted people in a hurry.

This client aims to cover all of the Pinboard [API v1](https://pinboard.in/api/).


## Requirements

* You must have a paid Pinboard account to use the API. It is a great service and you can [signup here](https://pinboard.in/signup/) if you don't already have an account.
* Currently tested on the following Ruby versions:
  * 1.9.2
  * 1.9.3
  * JRuby (1.9 mode)

_Note:_ Specs are currently passing on Rubinius with `RBXOPT=-X19` on my local machine but there is a failing spec on [Travis CI](http://travis-ci.org/#!/phlipper/pinboard_api). I will update the `README` with official support for Rubinus once everything runs smoothly on Travis.


## Installation

Add this line to your application's Gemfile:

```ruby
gem "pinboard_api"
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install pinboard_api
```


## Getting Started

You will need to set your username and password for the Pinboard service.

```ruby
PinboardApi.username = "phlipper"
PinboardApi.password = "[REDACTED]"
```

You may also set the SSL options which will be passed through to [Faraday](https://github.com/technoweenie/faraday#readme):

```ruby
PinboardApi.ssl_options = { ca_file: "/opt/local/share/curl/curl-ca-bundle.crt" }
```


## Usage

The `PinboardApi` namespace implements the 3 primary object types: `Post`, `Tag`, and `User`.


### Post


* [posts/update](https://pinboard.in/api#update) - Check to see when a user last posted an item.

```ruby
PinboardApi::Post.update
# => 2012-07-07 04:18:28 UTC
```

* ~~[posts/add](https://pinboard.in/api#posts_add) - add a new bookmark~~
* [posts/delete](https://pinboard.in/api#posts_delete) - delete an existing bookmark

```ruby
post = PinboardApi::Post.find(url: "https://pinboard.in/u:phlipper").first
post.destroy
# => #<PinboardApi::Post:0x007ffcb5166cf0 @description="Pinboard - antisocial bookmarking", @extended="", @hash="bc857ba651d134be0c9a5267e943c3ce", @url="https://pinboard.in/u:phlipper", @meta=nil, @tags="test", @time="2012-07-11T09:16:14Z">

PinboardApi::Post.destroy("https://pinboard.in/u:phlipper")
# => #<PinboardApi::Post:0x007f98d6946d78 @description="Pinboard - antisocial bookmarking", @extended="", @hash="bc857ba651d134be0c9a5267e943c3ce", @url="https://pinboard.in/u:phlipper", @meta=nil, @tags="test", @time="2012-07-11T09:17:36Z">
```

* [posts/get](https://pinboard.in/api#posts_get) - get bookmark for a single date, or fetch specific items by URL

```ruby
PinboardApi::Post.find(tag: "test")
# => [#<PinboardApi::Post:0x007fdce4547388 @description="Test.com – Certification Program Management – Create Online Tests with This Authoring, Management, Training and E-Learning Software", @extended="", @hash="dbb720d788ffaeb0afb7572104072f4a", @url="http://test.com/", @tags="test junk", @time="2012-07-07T04:18:28Z">, ...]

PinboardApi::Post.find(hash: "dbb720d788ffaeb0afb7572104072f4a", meta: "yes")
PinboardApi::Post.find(dt: Date.parse("2012-07-07"))
```

* [posts/dates](https://pinboard.in/api#posts_dates) - list dates on which bookmarks were posted

```ruby
PinboardApi::Post.dates
# => [{"count"=>1, "date"=>#<Date: 2012-07-10 ((2456119j,0s,0n),+0s,2299161j)>}, {"count"=>3, "date"=>#<Date: 2012-07-08 ((2456117j,0s,0n),+0s,2299161j)>}, ...]

PinboardApi::Post.dates(tag: "ruby")
```

* [posts/recent](https://pinboard.in/api#posts_recent) - fetch recent bookmarks

```ruby
PinboardApi::Post.recent
# => [#<PinboardApi::Post:0x007ffe150e1fd0 @description="Techniques to Secure Your Website with Ruby on Rails..."> ...]

PinboardApi::Post.recent(count: 3)
PinboardApi::Post.recent(tag: "ruby")
PinboardApi::Post.recent(count: 25, tag: ["ruby", "programming"])
```

* [posts/all](https://pinboard.in/api#posts_all) - fetch all bookmarks by date, tag, or range

```ruby
PinboardApi::Post.all
# => [#<PinboardApi::Post:0x007ffe150e1fd0 @description="Techniques to Secure Your Website with Ruby on Rails..."> ...]

PinboardApi::Post.all(tag: %w[ruby programming], meta: true, results: 30)
PinboardApi::Post.all(start: 50, fromdt: 2.weeks.ago, todt: 1.week.ago)
```

* [posts/suggest](https://pinboard.in/api#posts_suggest) - fetch popular and recommended tags for a url

```ruby
PinboardApi::Post.suggest("http://blog.com")
# => {"popular"=>["hosting", "blogs", "blog", "free"], "recommended"=>["blog", "blogging", "blogs", "free"]}
```


### Tag

* [tags/get](https://pinboard.in/api#tags_get) - fetch all tags

```ruby
PinboardApi::Tag.all
# => [#<PinboardApi::Tag:0x007fdce41f4f00 @name="leadership", @count=1>, #<PinboardApi::Tag:0x007fdce41f4e10 @name="date", @count=1>, ... ]

PinboardApi::Tag.find("leadership")
# => #<PinboardApi::Tag:0x007fdce4827eb8 @name="leadership", @count=1>
```

* [tags/delete](https://pinboard.in/api#tags_delete) - delete a tag from all bookmarks

```ruby
tag = PinboardApi::Tag.find("foo")
tag.destroy
# => #<PinboardApi::Tag:0x007fdce45f56e0 @name="foo", @count=1>

PinboardApi::Tag.destroy("foo")
# => #<PinboardApi::Tag:0x007fdce45f20f8 @name="foo", @count=1>
```

* [tags/rename](https://pinboard.in/api#tags_rename) - rename a tag

```ruby
tag = PinboardApi::Tag.find("foo")
# => #<PinboardApi::Tag:0x007fdce461bcc8 @name="foo", @count=1>

tag.rename("foo2")
# => #<PinboardApi::Tag:0x007fdce4c4bb48 @name="foo2", @count=1>
```


### User

* [user/secret](https://pinboard.in/api#user_secret) - get the secret RSS token (allows viewing user's private RSS feeds)

```ruby
PinboardApi::User.secret
# => "c3b0f4073ea37c4b1df5"
```


## TODO

* Implement Post.add/create
* Implement support for the new [`auth_token`](http://pinboard.in/api/#authentication)
* Implement support for rate limiting
* Cleanup/refactor internal exception handling


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## License

**pinboard_api**

* Freely distributable and licensed under the [MIT license](http://phlipper.mit-license.org/2012/license.html).
* Copyright (c) 2012 Phil Cohen (github@phlippers.net) [![endorse](http://api.coderwall.com/phlipper/endorsecount.png)](http://coderwall.com/phlipper)
* http://phlippers.net/
