class API::Profile < Grape::API
  format :json

  resources :profiles do
    get do
      remote(storage) { find :profiles, [:profile] }
    end

    namespace ':name' do
      get do
        content = remote(storage) { |p| read :profiles, p[:name] }
        MessagePack::unpack content
      end

      post do
        request.body.rewind
        content = MultiJson.load(request.body.read)

        remote(storage) do |p|
          write :profiles, p[:name], MessagePack.pack(content), [:profile]
        end
      end

      delete do
        remote(storage) { |p| remove :profiles, p[:name] }
      end
    end
  end

end
