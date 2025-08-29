class Withdrawal < Transaction
  validates :source_wallet, presence: true
  validates :target_wallet, absence: true
end
