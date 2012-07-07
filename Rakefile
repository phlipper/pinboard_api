#!/usr/bin/env rake
require "bundler/gem_tasks"
require "rake/testtask"

task :default => :spec

Rake::TestTask.new(:spec) do |t|
  t.libs << "lib"
  t.libs << "spec"
  t.pattern = "spec/**/*_spec.rb"
  t.verbose = false
end
