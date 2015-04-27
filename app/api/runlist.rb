class API::Runlist < Grape::API
  format :json

  resources :runlists do
    get do
      remote(storage) { find :runlists, [:runlist] }
    end

    namespace ':name' do
      get do
        content = remote(storage) { |p| read :runlists, p[:name] }
        MessagePack::unpack content
      end

      post do
        request.body.rewind
        content = MultiJson.load(request.body.read)

        remote(storage) do |p|
          write :runlists, p[:name], MessagePack.pack(content), [:runlist]
        end
      end

      delete do
        remote(storage) { |p| remove :runlists, p[:name] }
      end
    end
  end

end
