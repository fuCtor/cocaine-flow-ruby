class API::Runlists < Grape::API
  format :json

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
