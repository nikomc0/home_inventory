require 'warden'
require 'jwt'
require_relative '../models/user'

module Authentication
	class TokenStrategy < Warden::Strategies::Base
		def valid?
			access_token.present?
		end

		def authenticate!
			if access_token
				token = access_token.gsub('Bearer ', '')
			end
			
			begin
				decoded_token = JWT.decode token, nil, false
			rescue JWT::DecodeError
				error = JWT::DecodeError
			end
			
			user = User.where(password_digest: decoded_token[0]).first if decoded_token

			if user.nil?
				fail!('Could not log in')
			else
				user
				env['warden'].set_user(user)
				success!(user)
			end
		end

		private 

		def access_token
			@access_token ||= request.get_header('HTTP_AUTHORIZATION')
		end
	end
end