class API::App < Grape::API
  format :json

  helpers do
    def current_app
      @current_app ||= Cocaine::Service.new params[:name] if params[:name]
    rescue Cocaine::ServiceError
      error! 'service is not available', 404
    end
  end

  resources :apps do
    get do
      remote(storage) { find :manifests, [:app] }
    end

    post do
    end

    namespace ':name' do

      get do
        remote(current_app) { info }
      end

      delete ':name' do
      end

      post ':action' do
        params[:profile] ||= 'default'

        case params[:action]
          when :start
            remote(node) { |p| start_app p[:name], p[:profile] }
          when :stop
            remote(node) { |p| pause_app p[:name] }
          when :restart
            remote(node) { |p| pause_app p[:name] }
            remote(node) { |p| start_app p[:name], p[:profile] }
          else
            request.body.rewind
            content = MultiJson.load(request.body.read)

            result = remote(current_app, MessagePack.pack(content)) { |p| enqueue p[:action] }
            MessagePack.unpack(result)
        end
      end

      resources :logs do
        before do
          @keys = remote(storage) { |p| find :crashlogs, [p[:name]] }
        end
        get do
          @keys.map! do |k|
            time, key = k.split(':')
            [Time.at(time.to_i / 1000000), key]
          end
          Hash[@keys]
        end

        namespace ':key' do
          before do
            key = @keys.detect { |k| k =~ /#{params[:key]}$/ }
            error! 'log not found', 404 unless key
            params[:key] = key
          end

          get do
            MessagePack.unpack remote(storage) { |p| read :crashlogs, p[:key] }
          end

          delete do
            remote(storage) { |p| remove :crashlogs, p[:key] }
          end
        end
      end
    end
  end

end
