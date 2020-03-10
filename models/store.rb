class Store
	include Mongoid::Document

	field :name,       type: String
	field :total_items, type: Float, default: 0

	validates :name, presence: true

	index({ name: 'text' })

	scope :store, -> (store) { where(name: /^#{store}/)}
end