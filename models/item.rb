class Item
	include Mongoid::Document
  belongs_to :store
  accepts_nested_attributes_for :store

	field :name,  type: String
  field :store, type: Hash
  field :qty,   type: Float, default: 0
  # field :price, type: Float, default: 0.00
  # field :room,  type: String
  field :complete, type: Boolean, default: false

  validates :name,  presence: true

  index({ name: 'text' })

  scope :item,  -> (item) { where(name: /^#{item}/) }
  scope :store, -> (store) { where(store: /^#{store}/) }
  scope :room,  -> (room) { where(room: /^#{room}/) }
  scope :qty,   -> (qty)  {where(qty: /^#{qty}/) }
end