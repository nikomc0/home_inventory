class UnauthorizedController < Application
	before do
		content_type 'application/json'
	end

	get '/unauthenticated' do
		# redirect '/signup'
		halt 400, { message: 'Need to login' }.to_json
	end
end