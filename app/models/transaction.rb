class Transaction < ApplicationRecord
  self.inheritance_column = "transaction_type"

  belongs_to :source_wallet, class_name: "Wallet", optional: true
  belongs_to :target_wallet, class_name: "Wallet", optional: true

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true
end
