begin
  require "simplecov"
  SimpleCov.add_filter "spec"
  SimpleCov.command_name "MiniTest"
  SimpleCov.start
rescue LoadError
  warn "unable to load 'simplecov'"
end

require "minitest/autorun"
require "minitest/pride"
require "mocha"

require File.expand_path("../../lib/pinboard_api", __FILE__)

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join("./spec/support/**/*.rb")].sort.each { |f| require f }
