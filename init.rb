#!/usr/local/bin/ruby
$:.unshift File.dirname($0) 
require 'bundler' 
require 'bundler/setup'

Bundler.require

APP_ROOT = File.expand_path('..', __FILE__)

Dir[File.join(APP_ROOT, 'app', '*.rb')].each { |file| require file }
