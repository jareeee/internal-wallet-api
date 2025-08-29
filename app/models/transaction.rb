class Transaction < ApplicationRecord
  belongs_to :source_wallet
  belongs_to :target_wallet
end
