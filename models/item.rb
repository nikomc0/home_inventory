class Item
	include Mongoid::Document

	field :name,  type: String
  field :store, type: String
  field :price, type: Float
  field :room,  type: String

  validates :name,  presence: true
  validates :store, presence: true
  validates :price, presence: true
  validates :room,  presence: true

  index({ name: 'text' })

  scope :name,  -> (name) { where(name: /^#{name}/) }
  scope :store, -> (store) { where(store: /^#{store}/) }
  scope :room,  -> (room) { where(room: /^#{room}/) }
end