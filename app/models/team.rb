class Team < ApplicationRecord
  has_many :wallets, as: :walletable, dependent: :destroy
  has_many :team_memberships, dependent: :destroy
  has_many :members, through: :team_memberships, source: :user

  validates :name, presence: true

  def wallet_accessible_by?(user)
    members.include?(user)
  end

  def create_wallet!(currency: "IDR")
    wallets.create!(currency: currency)
  end
end
