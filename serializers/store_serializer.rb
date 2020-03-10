class StoreSerializer
	def initialize(store)
		@store = store
	end

	def as_json(*)
		stores = {
			id: @store.id.to_s,
			name: @store.name,
			total_items: @store.total_items
		}

		stores[:errors] = @store.errors if @store.errors.any?
		stores
	end
end