require 'sinatra'
require 'dotenv/load'
require "sinatra/namespace"
require'mongoid'
require_relative './models/item'
require_relative './models/store'

Mongoid.load!("mongoid.config", :production)

class Application < Sinatra::Base
	get '/' do
	  'Welcome to BookList!'
	end
end
