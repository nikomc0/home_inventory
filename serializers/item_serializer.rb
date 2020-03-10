class ItemSerializer
	def initialize(item)
		@item = item
	end

	def as_json(*)
		data = {
			id: @item.id.to_s,
			item: @item.name,
			store: { id: @item.store['id'].to_s, name: @item.store['name']},
			price: @item.price,
			room: @item.room,
			qty: @item.qty
		}

		data[:errors] = @item.errors if @item.errors.any?
		data
	end
end