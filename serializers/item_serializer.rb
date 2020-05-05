class ItemSerializer
	def initialize(item)
		@item = item
	end

	def as_json(*)
		data = {
			id: @item.id.to_s,
			name: @item.name,
			store_info: { id: @item.store_id.to_s, store_name: @item.store.name},
			qty: @item.qty,
			complete: @item.complete,
			created_at: @item.created_at,
			updated_at: @item.updated_at
		}

		data[:errors] = @item.errors if @item.errors.any?
		data
	end
end