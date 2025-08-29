class Stock < ApplicationRecord
  belongs_to :user
  has_one :wallet, as: :walletable, dependent: :destroy

  validates :symbol, presence: true

  def wallet_accessible_by?(user)
    self.user == user
  end
end
