class ItemSerializer
	def initialize(item)
		@item = item
	end

	def as_json(*)
		data = {
			id: @item.id.to_s,
			item: @item.item,
			store: @item.store,
			price: @item.price,
			room: @item.room,
			qty: @item.qty
		}

		data[:errors] = @item.errors if @item.errors.any?
		data
	end
end