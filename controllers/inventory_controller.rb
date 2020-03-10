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

  attr_accessor :item, :store

  @item = nil
  @store = nil

	namespace '/api/v1' do
	  get '/items' do
	  	items = Item.all.sort({'store': 1})
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
	 			add_item(parameters)
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

			@item ||= Item.new(name: parameters['item'])
			@item.qty += 1

			@store ||= Store.new(name: parameters['store'])
			@store.total_items += 1

			@item.store = StoreSerializer.new(@store).as_json

			if @item.save && @store.save
				# response.headers['Location'] = "#{base_url}/api/v1/items/#{item.id}"
				status 201
			else
				status 422
				body ItemSerializer.new(item).to_json
			end
	 	end

	 	def delete_item(parameters)
	 		parameters = clean_params(parameters)
	 		item = Item.where(name: parameters['item']).first
	 		store = Store.where(item.store)

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
 		existing_item = Item.where(name: params['item']).first
		existing_store = Store.where(name: params['store']).first

		if existing_item
			@item = existing_item
		end

		if existing_store
			@store = existing_store
		end
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