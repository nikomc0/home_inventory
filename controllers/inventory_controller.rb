require './server'
require_relative '../helpers/url_helper'
require_relative '../serializers/item_serializer'
require_relative '../serializers/store_serializer'
require 'pry-byebug'

class InventoryController < Application
	register Sinatra::Namespace
	include URLHelper

	before do
    content_type 'application/json'
  end

	namespace '/api/v1' do
	  get '/items' do
	  	items = Item.all
	  	stores = Store.all

	  	[:item, :store, :room].each do |filter|
	  		items = items.send(filter, params[filter]) if params[filter]
	  	end

	  	list_items = items.map { |item| ItemSerializer.new(item) }
	  	list_stores = stores.map { |store| StoreSerializer.new(store) }

	  	{ items: list_items, stores: list_stores }.to_json
	  end

	 	post '/items' do
	 		params = json_params
	 		action = params['queryResult']['action']
	 		parameters = clean_params(params['queryResult']['parameters'])

	 		case action
	 		when "Inventory.Inventory-yes"
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
	 		existing_item = Item.where(item: parameters['item']).first

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

				existing_store = Store.where(store: parameters['store'])
				store = Store.new(store: parameters['store'])

				if !existing_store
					store.save
				end

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
	 		parameters = clean_params(parameters)
	 		item = Item.where(item: parameters['item']).first
	 		item.destroy if item
	 		status 204
	 	end

	 	def delete_all
	 		items = Item.all
	 		stores = Store.all

	 		[items, stores].each do |t|
	 			t.destroy 
	 		end
	 		status 204
	 	end
	end

	private
	def clean_params(params)
		params.map do |t| 
			t.map do |z|
				z.downcase.gsub(/[^0-9A-Za-z ]/,"")
			end
		end.to_h
	end
end