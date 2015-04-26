
class API < Grape::API
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
#      puts "ID: #{id} #{value.inspect}"
      error! value.last, 400 if id.to_s == 'error'
      value[0]
    end

  end

  resources :apps do
    get '/' do
      stage() { storage.find :manifests, [:app] }
    end

    post '/' do
    end

    namespace '/:name' do
      get '/' do
        service = Cocaine::Service.new params[:name]
        stage() { service.info }
      end
 
      delete '/:name' do
      end

      post '/:action' do		
        params[:profile] ||= 'default'

        case params[:action]
        when :start
          stage() { node.start_app params[:name], params[:profile] }
        when :stop
          stage() { node.pause_app params[:name] }
        when :restart
          stage() { node.pause_app params[:name] }
          stage() { node.start_app params[:name], params[:profile] }
	else 
	  service = Cocaine::Service.new params[:name]

          request.body.rewind
          data = MultiJson.load(request.body.read)

          result = stage MessagePack.pack(data) do
            service.enqueue params[:action]
	  end
          MessagePack.unpack(result)
        end
      end

      resources :logs do
        get do
          keys = stage() { storage.find :crashlogs, [params[:name]] }
          keys.map! do |k| 
            time, key = k.split(':') 
            time = Time.at (time.to_i  / 1000000)
            [time,key]
          end
          Hash[keys]
        end
        namespace ':key' do
          get do
            keys = stage() { storage.find :crashlogs, [params[:name]] }
            keys.map! {|k| k.split(':') }
	    key = keys.detect {|k| k[1] == params[:key] }
            error! "log not found", 404 unless key
            key = key.join(':')
            content = stage() { storage.read :crashlogs, key }
            MessagePack.unpack content
          end
        end
      end

    end

  end

  resources :profiles do
    get do
      stage() { storage.find :profiles, [:profile] }
    end

    namespace ':name' do
      get do
        profile = stage() { storage.read :profiles, params[:name] }
        MessagePack::unpack profile
      end
      
      post do
        request.body.rewind
        data = MultiJson.load(request.body.read)

        stage do
          storage.write :profiles, params[:name], MessagePack.pack(data), [:profile]
        end
      end
      
      delete do
        stage do
          storage.remove :profiles, params[:name]
        end
      end
    end    

  end

  resources :runlists do
    get do
      stage() { storage.find :runlists, [:runlist] }
    end

    namespace ':name' do
      get do
        content = stage() { storage.read :runlists, params[:name] }
        MessagePack::unpack content
      end

      post do
        request.body.rewind
        content = MultiJson.load(request.body.read)

        stage do
          storage.write :runlists, params[:name], MessagePack.pack(content), [:runlist]
        end
      end

      delete do
        stage do
          storage.remove :runlists, params[:name]
        end
      end
    end
    
  end

end
