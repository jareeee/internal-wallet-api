class User < ApplicationRecord
	has_secure_password

	# Associations
	has_one :wallet, as: :walletable, dependent: :destroy
	has_many :team_memberships, dependent: :destroy
	has_many :teams, through: :team_memberships
	has_many :stocks, dependent: :destroy

	# Validations
	validates :name, presence: true
	validates :email, presence: true,
										uniqueness: true,
										format: { with: URI::MailTo::EMAIL_REGEXP }
end
