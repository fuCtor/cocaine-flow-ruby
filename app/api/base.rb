class API::Base < Grape::API
  version 'v1', using: :path
  format :json
  prefix :api

  helpers do
    def storage
      @storage ||= Cocaine::Service.new :storage
    rescue Cocaine::ServiceError
      error! 'storage service is not available', 404
    end

    def node
      @node ||= Cocaine::Service.new :node
    rescue Cocaine::ServiceError
      error! 'node service is not available', 404
    end

    def remote(service = nil, data = nil, &block)
      return unless block

      tx, rx = if service
                 service.instance_exec params, &block
               else
                 block.call(params) if block
               end
      tx.write data if data && tx

      return unless rx
      id, value = rx.recv
      error! value.last, 400 if id.to_s == 'error'
      value[0]
    end
  end
  
  mount API::App
  mount API::Profile
  mount API::Runlist
  
end
