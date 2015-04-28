#!/usr/local/bin/ruby
$:.unshift File.dirname($0) 
require 'bundler' 
require 'bundler/setup'

Bundler.require

APP_ROOT = File.expand_path('..', __FILE__)

Dir[File.join(APP_ROOT, 'app', '*.rb')].each { |file| require file }

Thin::Server.class_eval do
  def stop_with_connection_closing
    App.connections.dup.each(&:close)
    stop_without_connection_closing
  end

  alias_method :stop_without_connection_closing, :stop
  alias_method :stop, :stop_with_connection_closing
end