class User
	include Mongoid::Document
	include Mongoid::Timestamps
	include ActiveModel::SecurePassword

	has_many :stores
	accepts_nested_attributes_for :stores

	field :email,             type: String
	field :password_digest,   type: String

	validates :email, presence: true, uniqueness: true
	validates :password_digest, presence: true

	has_secure_password
end
