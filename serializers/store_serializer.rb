class StoreSerializer
	def initialize(store)
		@store = store
	end

	def as_json(*)
		items = []

		@store.items.each do |t|
			items.push(ItemSerializer.new(t).as_json)
		end

		stores = {
			id: @store.id.to_s,
			name: @store.name,
			total_items: @store.total_items,
			items: items
		}

		stores[:errors] = @store.errors if @store.errors.any?
		stores
	end
end