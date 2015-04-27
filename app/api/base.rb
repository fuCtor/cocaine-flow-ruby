class API::Base < Grape::API
  version 'v1', using: :path
  format :json
  prefix :api

  class Error < StandardError; end

  helpers do
    def storage
      @storage ||= Cocaine::Service.new :storage
    end
    
    def node
      @node ||= Cocaine::Service.new :node
    end
    
    def stage(data = nil)
      tx, rx = yield
      tx.write data if data
      id, value = rx.recv
      error! value.last, 400 if id.to_s == 'error'
      value[0]
    end
  end
  
  mount API::Apps
  mount API::Profiles
  mount API::Runlists
  
end
