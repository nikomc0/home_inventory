class Store
	include Mongoid::Document

	field :store, type: String

	validates :store, presence: true

	index({ item: 'text' })

	scope :store, -> (store) { where(store: /^#{store}/)}
end