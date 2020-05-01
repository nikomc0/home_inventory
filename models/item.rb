class Item
	include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :store

  # accepts_nested_attributes_for :store

	field :name,       type: String
  field :store_info, type: Hash
  field :qty,        type: Float, default: 0
  field :complete,   type: Boolean, default: false
  field :user_id,    type: String

  validates :name,  presence: true

  index({ name: 'text' })

  scope :complete, -> { where(complete: false) }
end