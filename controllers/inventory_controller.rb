require './server'
require_relative '../helpers/url_helper'
require_relative '../serializers/item_serializer'

class InventoryController < Application
	register Sinatra::Namespace
	include URLHelper

	before do
    content_type 'application/json'
  end

	namespace '/api/v1' do
	  get '/items' do
	  	items = Item.all

	  	[:item, :store, :room].each do |filter|
	  		items = items.send(filter, params[filter]) if params[filter]
	  	end

	  	items.map { |item| ItemSerializer.new(item) }.to_json
	  end

	 	post '/items' do
	 		item = Item.new(json_params)

	 		if item.save
	 			response.headers['Location'] = "#{base_url}/api/v1/items/#{item.id}"
	 			status 201
	 		else
	 			status 422
	 			body ItemSerializer.new(item).to_json
	 		end
	 	end

	 	patch '/items/:id' do |id|
	 		item = Item.where(id: id).first
	 		halt(404, { message: 'Item not found' }.to_json) unless item

	 		if item.update_attributes(json_params)
	 			ItemSerializer.new(item).to_json
	 		else
	 			status 422
	 			body ItemSerializer.new(item).to_json
	 		end
	 	end

	 	delete '/items/:id' do |id|
	 		item = Item.where(id: id).first
	 		item.destroy if item
	 		status 204
	 	end
	end
end