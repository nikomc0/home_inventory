class Item
	include Mongoid::Document

	field :item,  type: String
  field :store, type: String
  field :price, type: Float
  field :room,  type: String
  field :qty,   type: Float

  validates :item,  presence: true
  validates :store, presence: true
  validates :room,  presence: true

  index({ item: 'text' })

  scope :item,  -> (item) { where(item: /^#{item}/) }
  scope :store, -> (store) { where(store: /^#{store}/) }
  scope :room,  -> (room) { where(room: /^#{room}/) }
  scope :qty,   -> (qty)  {where(qty: /^#{qty}/) }
end