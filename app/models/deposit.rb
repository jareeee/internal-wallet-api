class Deposit < Transaction
  validates :target_wallet, presence: true
  validates :source_wallet, absence: true
end
