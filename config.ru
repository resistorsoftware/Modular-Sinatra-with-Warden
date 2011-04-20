require 'bundler/setup'
Bundler.require(:default)

require 'active_record'
require 'bcrypt'
require 'logger'

use Rack::Session::Cookie, :key => 'rack.session',
                            :path => '/',
                            :expire_after => 600, # In seconds
                            :secret => 'change_me'
use Rack::Flash
 
require File.dirname(__FILE__) + "/main.rb"

# load DB models
Dir['models/*.rb'].each {|file| require "./#{file}"}

Warden::Manager.serialize_into_session{|user| user.id }
Warden::Manager.serialize_from_session{|id| User.get(id) }

Warden::Manager.before_failure do |env,opts|
  env['REQUEST_METHOD'] = "POST"
end

Warden::Strategies.add(:password) do

  def valid?
    params["email"] || params["password"]
  end

  def authenticate!
    user = User.authenticate(params["email"], params["password"])
    unless user.instance_of?(User)
      case user   # we failed to find a User account.. let's try and see why
        when 'email'
          fail!("#{params['email']} email address was not found in the application.")
        when 'password'
          fail!("#{params['email']} has a different password than the one provided.")
      end  
    else
      env['warden'].set_user(user, :scope => :admin) if user.admin == true
      success!(user)
    end
    
  end
end

use Warden::Manager do |manager|
  manager.default_strategies :password
  manager.failure_app = Poobah::FailureApp.new
end

map '/' do
  run Poobah::Public
end

map '/admin' do
  run Poobah::Admin
end

map '/special' do
  run Poobah::Special
end