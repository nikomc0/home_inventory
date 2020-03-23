class Store
	include Mongoid::Document
	has_many :items

	field :name,        type: String
	field :total_items, type: Float, default: 0

	validates :name, presence: true

	index({ name: 'text' })

	# scope :name, -> { where(name: 'target') }
end