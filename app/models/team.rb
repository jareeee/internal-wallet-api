class Team < ApplicationRecord
	# Associations
	has_one :wallet, as: :walletable, dependent: :destroy
	has_many :team_memberships, dependent: :destroy
	has_many :members, through: :team_memberships, source: :user

	# Validations
	validates :name, presence: true
end
