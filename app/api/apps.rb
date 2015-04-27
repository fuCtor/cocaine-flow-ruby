class API::Apps < Grape::API
  format :json

  helpers do
    def storage
      @storage ||= Cocaine::Service.new :storage
    end
    
    def node
      @node ||= Cocaine::Service.new :node
    end
    
    def remote(service, data = nil, &block)
	  return unless block
      tx, rx = service.instance_exec params, &block
      tx.write data if data
      id, value = rx.recv
      error! value.last, 400 if id.to_s == 'error'
      value[0]
    end
  end

  resources :apps do
    get '/' do
      remote(storage) { find :manifests, [:app] }
    end

    post '/' do
    end

    namespace '/:name' do
      get '/' do
        service = Cocaine::Service.new params[:name]
        remote(service) { service.info }
      end
 
      delete '/:name' do
      end

      post '/:action' do		
        params[:profile] ||= 'default'

        case params[:action]
        when :start
          remote(node) { |params| start_app params[:name], params[:profile] }
        when :stop
          remote(node) { |params| pause_app params[:name] }
        when :restart
          remote(node) { |params| pause_app params[:name] }
          remote(node) { |params| start_app params[:name], params[:profile] }
		else 
		  service = Cocaine::Service.new params[:name]

          request.body.rewind
          data = MultiJson.load(request.body.read)

          result = remote(service, MessagePack.pack(data)) do |params|
            enqueue params[:action]
	      end
          MessagePack.unpack(result)
        end
      end

      resources :logs do
        get do
          keys = remote(storage) { |params| find :crashlogs, [ params[:name] ] }
          keys.map! do |k| 
            time, key = k.split(':') 
            [Time.at(time.to_i  / 1000000), key]
          end
          Hash[keys]
        end
        namespace ':key' do
          get do	
			key = remote(storage) { |params| find :crashlogs, [params[:name]] } .detect {|k| k =~ /#{params[:key]}$/ }
			
            error! "log not found", 404 unless key

            content = remote(storage) { read :crashlogs, key }
            MessagePack.unpack content
          end
        end
      end

    end

  end

end
