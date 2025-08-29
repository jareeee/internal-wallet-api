class Transfer < Transaction
  validates :source_wallet, presence: true
  validates :target_wallet, presence: true
end
