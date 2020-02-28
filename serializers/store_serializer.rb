class StoreSerializer
	def initialize(store)
		@store = store
	end

	def as_json(*)
		stores = {
			id: @store.id.to_s,
			store: @store.store
		}

		stores[:errors] = @store.errors if @store.errors.any?
		stores
	end
end