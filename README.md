# PinboardApi [![Build Status](https://secure.travis-ci.org/phlipper/pinboard_api.png?branch=master)](http://travis-ci.org/phlipper/pinboard_api)

## Description

A Ruby API client for [Pinboard.in](https://pinboard.in/), the bookmarking website for introverted people in a hurry.

This client aims to cover all of the Pinboard [API v1](https://pinboard.in/api/).


## Requirements

* This library requires Ruby 1.9.2 or newer.
* You must have a paid Pinboard account to use the API. It is a great service and you can [signup here](https://pinboard.in/signup/) if you don't already have an account.


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


## Usage

The `PinboardApi` namespace implements the 3 primary object types: `Post`, `Tag`, and `User`.


### Post


* [posts/update](https://pinboard.in/api#update) - Check to see when a user last posted an item.

```ruby
PinboardApi::Post.update
# => 2012-07-07 04:18:28 UTC
```

* ~~[posts/add](https://pinboard.in/api#posts_add) - add a new bookmark~~
* ~~[posts/delete](https://pinboard.in/api#posts_delete) - delete an existing bookmark~~
* [posts/get](https://pinboard.in/api#posts_get) - get bookmark for a single date, or fetch specific items by URL

```ruby
PinboardApi::Post.find(tag: "test")
# => [#<PinboardApi::Post:0x007fdce4547388 @description="Test.com – Certification Program Management – Create Online Tests with This Authoring, Management, Training and E-Learning Software", @extended="", @hash="dbb720d788ffaeb0afb7572104072f4a", @href="http://test.com/", @tags="test junk", @time="2012-07-07T04:18:28Z">, ...]

PinboardApi::Post.find(hash: "dbb720d788ffaeb0afb7572104072f4a", meta: "yes")
# => [#<PinboardApi::Post:0x007fac2b9d6690 @description="Test.com – Certification Program Management – Create Online Tests with This Authoring, Management, Training and E-Learning Software", @extended="", @hash="dbb720d788ffaeb0afb7572104072f4a", @href="http://test.com/", @meta="73b192512e3e4829806f5eee0a6b456d", @tags="test junk", @time="2012-07-07T04:18:28Z">, ...]

PinboardApi::Post.find(dt: Date.parse("2012-07-07"))
# => [#<PinboardApi::Post:0x007fac2ba0fdf0 @description="Test.com – Certification Program Management – Create Online Tests with This Authoring, Management, Training and E-Learning Software", @extended="", @hash="dbb720d788ffaeb0afb7572104072f4a", @href="http://test.com/", @meta=nil, @tags="test junk", @time="2012-07-07T04:18:28Z">, ...]
```

* ~~[posts/dates](https://pinboard.in/api#posts_dates) - list dates on which bookmarks were posted~~
* ~~[posts/recent](https://pinboard.in/api#posts_recent) - fetch recent bookmarks~~
* ~~[posts/all](https://pinboard.in/api#posts_all) - fetch all bookmarks by date, tag, or range~~
* ~~[posts/suggest](https://pinboard.in/api#posts_suggest) - fetch popular and recommended tags for a url~~


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
# => #<PinboardApi::Tag:0x007fdce45f56e0 @name="foo", @count=1>

tag.delete
# => #<PinboardApi::Tag:0x007fdce45f56e0 @name="foo", @count=1>

tag = PinboardApi::Tag.find("foo")
# => nil
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
