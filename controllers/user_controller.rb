require './server'
require_relative '../helpers/url_helper'
require 'warden'
require 'jwt'

class UserController < Application
	include URLHelper

	before do
		content_type 'application/json'
	end

	post '/signup' do
		params = json_params
		email = params['email']
		password = params['password']

		user = User.new(email: email, password: password)

		if user.save
		 	token = JWT.encode user.password_digest, nil, 'none'
			status 200
			{token: token}.to_json
		else
			status 422
			user.errors.messages.to_json
		end
	end

	post '/signin' do
		params = json_params
		email = params['email']
		password = params['password']

		user = User.where(email: email).first

		if user && user.authenticate(password)
			env['warden'].set_user(user)
			token = JWT.encode user.password_digest, nil, 'none'
			{user: {email: user.email }, token: token}.to_json
		else
			status 422
			{messages: ["Invalid Email or Password."]}.to_json
		end
	end

	post '/signout' do
		env['warden'].logout
		session.clear
	end

end