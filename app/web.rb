#http://www.html5rocks.com/en/tutorials/eventsource/basics/

class Web < Sinatra::Base

  configure do
    set server: 'thin'

    set :assets_precompile, %w(application.js application.css *.png *.jpg *.svg *.eot *.ttf *.woff)
    set :assets_css_compressor, :sass
    set :assets_js_compressor, :uglifier
    set :views, File.join(APP_ROOT, 'views')

    register Sinatra::AssetPipeline

    # Actual Rails Assets integration, everything else is Sprockets
    if defined?(RailsAssets)
      RailsAssets.load_paths.each do |path|
        settings.sprockets.append_path(path)
      end
    end

    %w(js css fonts images).each do |path|
      settings.sprockets.append_path(File.join(APP_ROOT, 'assets', path))
    end
  end

  get '/events', provides: 'text/event-stream' do
    response.headers['X-Accel-Buffering'] = 'no' # Disable buffering for nginx
    stream :keep_open do |out|
      App.connections << out
      out << App.latest_events
      out.callback { App.connections.delete(out) }
    end
  end

  get "/__tpl/:name" do
    puts params
    haml params[:name].to_sym
  end

  get '/' do
    haml :index
  end
end
