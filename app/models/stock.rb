class Stock < ApplicationRecord
  belongs_to :user
  has_many :wallets, as: :walletable, dependent: :destroy

  validates :symbol, presence: true

  def wallet_accessible_by?(user)
    self.user == user
  end

  def create_wallet!(currency: "IDR")
    wallets.create!(currency: currency)
  end
end
