# Modular App Test with Sinatra-Warden

module Poobah
  
  class FailureApp
    def call(env)
      env['x-rack.flash'][:notice] = env['warden'].message unless env['x-rack.flash'].nil?
      [302, {'Location' => env['warden.options'][:attempted_path], 'Content-type' => 'text/html'},'']
    end
  end         
  
  class Public < Sinatra::Base
    configure do
      config = YAML::load(File.open('config/database.yml'))
      environment = settings.environment.to_s
      ActiveRecord::Base.establish_connection(config[environment])
      ActiveRecord::Base.logger = Logger.new($stdout)
    end
    
    set :session_secret, "public sinatra app"
    
    get '/' do
      if env['warden'].authenticated? || env['warden'].authenticated?(:admin)
        haml :index
      else
        redirect '/login'
      end
    end
    
    get '/login' do
      flash[:notice] = env['x-rack.flash'][:notice] unless env['x-rack.flash'].nil? 
      haml :login
    end
    
    get '/logout/?' do
      env['warden'].logout
      redirect '/'
    end
    
    post '/login' do
      env['warden'].authenticate!
      redirect('/')
    end
    
    post '/unauthenticated/?' do
      status 401
      haml :login
    end
    
  end
   
  class Admin < Sinatra::Base
    
    set :session_secret, "admin sinatra app"
    
    get '/' do
      if env['warden'].authenticated?(:admin)
        haml :'admin/index'
      else
        redirect '/admin/login'
      end
    end

    get '/login' do
      flash[:notice] = env['x-rack.flash'][:notice] unless env['x-rack.flash'].nil?
      haml :'admin/login'
    end

    post '/login' do
      env['warden'].authenticate! :scope => :admin
      redirect('/admin')
    end

    post '/unauthenticated/?' do
      status 401
      haml :'admin/login'
    end
  end
   
  class Special < Sinatra::Base
    get '/' do
      haml :'special/index'
    end
  end
   
end