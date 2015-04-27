class API::Profiles < Grape::API
  format :json
  
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

end
