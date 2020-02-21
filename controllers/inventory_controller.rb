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
	 		params = json_params
	 		action = params['queryResult']['action']
	 		parameters = params['queryResult']['parameters']

	 		case action
	 		when "add_item"
	 			add_item(parameters)
	 		when "delete_item"
	 			delete_item(parameters)
	 		when "delete_all"
	 			delete_all
	 		else
	 			item = Item.new(parameters)
				item.qty = 1

				if item.save
					response.headers['Location'] = "#{base_url}/api/v1/items/#{item.id}"
					status 201
				else
					status 422
					body ItemSerializer.new(item).to_json
				end
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

	 	def add_item(parameters)
	 		existing_item = Item.where(item: parameters['item'], room: parameters['room']).first

	 		if existing_item
	 			existing_item.qty += 1
	 			
	 			if existing_item.save
					response.headers['Location'] = "#{base_url}/api/v1/items/#{existing_item.id}"
					status 201
				else
					status 422
					body ItemSerializer.new(existing_item).to_json
				end
	 		else
				item = Item.new(parameters)
				item.qty = 1

				if item.save
					response.headers['Location'] = "#{base_url}/api/v1/items/#{item.id}"
					status 201
				else
					status 422
					body ItemSerializer.new(item).to_json
				end
			end
	 	end

	 	def delete_item(parameters)
	 		item = Item.where(item: parameters['item'], room: parameters['room']).first
	 		item.destroy if item
	 		status 204
	 	end

	 	def delete_all
	 		items = Item.all
	 		items.each do |t|
	 			t.destroy 
	 		end
	 		status 204
	 	end
	end
end