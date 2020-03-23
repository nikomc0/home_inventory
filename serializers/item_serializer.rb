class ItemSerializer
	def initialize(item)
		@item = item
	end

	def as_json(*)
		data = {
			id: @item.id.to_s,
			item: @item.name,
			store_info: { id: @item.store_id.to_s, name: @item.store.name},
			# price: @item.price,
			# room: @item.room,
			qty: @item.qty,
			complete: @item.complete
		}

		data[:errors] = @item.errors if @item.errors.any?
		data
	end
end