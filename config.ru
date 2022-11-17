require 'sinatra'
require 'warden'
require_relative './server'
require_relative './controllers/inventory_controller'
require_relative './controllers/user_controller'
require_relative './authentication/token_strategy'
require_relative './controllers/unauthorized_controller'

# Authentication
use Rack::Session::Cookie, :secret => 'MY_SECRET_SECRET'
Warden::Strategies.add(:token, ::Authentication::TokenStrategy)
Warden::Manager.serialize_into_session do |user|
  user.id
end

Warden::Manager.serialize_from_session do |id|
  User.find(id)
end

use Warden::Manager do |manager|
	manager.default_strategies [:token]
	manager.failure_app = UnauthorizedController
end

# Application
use UserController
use InventoryController
run Application
