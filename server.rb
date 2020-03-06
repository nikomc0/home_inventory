require 'sinatra'
require "sinatra/namespace"
require'mongoid'
require_relative './models/item'
require_relative './models/store'

Mongoid.load!("mongoid.config", :development)

class Application < Sinatra::Base
	get '/' do
	  'Welcome to BookList!'
	end
end
