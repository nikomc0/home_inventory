require './server'
require_relative '../helpers/url_helper'
require_relative '../serializers/item_serializer'
require_relative '../serializers/store_serializer'
require 'pry-byebug'
require 'prettyprint'

class InventoryController < Application
	register Sinatra::Namespace
	include URLHelper

	before do
    content_type 'application/json'
  end

  attr_accessor :item, :store

  @item = nil
  @store = nil

	namespace '/api/v1' do
	  get '/items' do
	  	items = Item.all
	  	stores = Store.all

	  	[:item, :store, :room].each do |filter|
	  		items = items.send(filter, params[filter]) if params[filter]
	  	end

	  	list_items = items.map { |item| ItemSerializer.new(item) } if items
	  	list_stores = stores.map { |store| StoreSerializer.new(store) } if stores

	  	{ items: list_items, stores: list_stores }.to_json
	  end

	 	post '/items' do
	 		params = json_params

	 		if params['queryResult']
	 			action = params['queryResult']['action']
	 			parameters = clean_params(params['queryResult']['parameters'])
	 		else
	 			action = ""
	 			parameters = clean_params(params)
	 		end

	 		case action
	 		when "delete_item"
	 			delete_item(parameters)
	 		when "delete_all"
	 			delete_all
	 		else
	 			return add_item(parameters)
	 		end
	 	end

	 	put '/items/:id' do |id|
	 		params = json_params

	 		item = Item.where(id: id).first
	 		# halt(404, { message: 'Item not found' }.to_json) unless item

	 		if item.update_attributes(params['item'])
	 			body ItemSerializer.new(item).to_json
	 			status 201
	 		else
	 			status 422
	 			body ItemSerializer.new(item).to_json
	 		end
	 	end

	 	delete '/items/:id' do |id|
	 		item = Item.where(id: params['id']).first
	 		store = Store.where(item.store).first

	 		if store.total_items > 1
	 			store.total_items -= 1
	 			store.save
	 		else
	 			store.destroy if store
	 		end

	 		item.destroy if item
	 		status 204
	 	end

	 	def add_item(parameters)
	 		value_exists?(parameters)

			@item ||= Item.new(name: parameters['item'], store: {name: parameters['store']})
			@item.store_info = StoreSerializer.new(@item.store).as_json
	 		@item.store.total_items += 1
			@item.qty += 1

	 		@store = @item.store

			if @item.save && @store.save
				# response.headers['Location'] = "#{base_url}/api/v1/items/#{item.id}"
				body ItemSerializer.new(@item).to_json
				status 201
			else
				status 422
				body ItemSerializer.new(item).to_json
			end
	 	end

	 	def delete_item(parameters)
	 		parameters = clean_params(parameters)
	 		item = Item.where(name: parameters['item']).first
	 		store = Store.where(item.store).first

	 		if store.total_items > 1
	 			store.total_items -= 1
	 			store.save
	 		else
	 			store.destroy if store
	 		end

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
	def value_exists?(params)
		existing_item = Item.where({name: params['item'], 'store_info.name': params['store']}).first
		existing_store = Store.where(name: params['store']).first

		@item = existing_item if existing_item
		@store = existing_store if existing_store
	end

	def clean_params(params)
		params.map do |t| 
			t.map do |z|
				# removes leading/trailing spaces and special characters
				z.downcase.gsub(/[^0-9A-Za-z ]+/,"").strip()
			end
		end.to_h
	end
end
