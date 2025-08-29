class Transaction < ApplicationRecord
  # Use custom STI column
  self.inheritance_column = 'transaction_type'

  # Associations
  belongs_to :source_wallet, class_name: 'Wallet', optional: true
  belongs_to :target_wallet, class_name: 'Wallet', optional: true

  # Validations
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true
end
