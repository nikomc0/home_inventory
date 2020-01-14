class ItemSerializer
	def initialize(item)
		@item = item
	end

	def as_json(*)
		data = {
			id: @item.id.to_s,
			name: @item.name,
			store: @item.store,
			price: @item.price,
			room: @item.room
		}

		data[:errors] = @item.errors if @item.errors.any?
		data
	end
end