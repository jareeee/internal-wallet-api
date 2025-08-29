class User < ApplicationRecord
  has_secure_password

  has_many :wallets, as: :walletable, dependent: :destroy
  has_many :team_memberships, dependent: :destroy
  has_many :teams, through: :team_memberships
  has_many :stocks, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true,
                    uniqueness: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  def wallet_accessible_by?(user)
    self == user
  end

  def create_wallet!(currency: "IDR")
    wallets.create!(currency: currency)
  end
end
