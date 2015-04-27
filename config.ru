require './init'

use Rack::Session::Cookie
run Rack::Cascade.new [API::Base, Web]
