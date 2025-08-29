class Wallet < ApplicationRecord
  belongs_to :walletable, polymorphic: true

  has_many :balance_snapshots, dependent: :destroy
  has_many :outgoing_transactions, class_name: "Transaction", foreign_key: "source_wallet_id", dependent: :destroy
  has_many :incoming_transactions, class_name: "Transaction", foreign_key: "target_wallet_id", dependent: :destroy

  def calculate_balance
    last_snapshot = balance_snapshots.order(snapshot_date: :desc, created_at: :desc).first

    starting_balance = last_snapshot&.balance_amount.to_d || 0.to_d
    snapshot_cutoff = last_snapshot&.snapshot_date&.to_time&.end_of_day

    if snapshot_cutoff
      incoming = incoming_transactions.where("created_at > ?", snapshot_cutoff).sum(:amount)
      outgoing = outgoing_transactions.where("created_at > ?", snapshot_cutoff).sum(:amount)
    else
      incoming = incoming_transactions.sum(:amount)
      outgoing = outgoing_transactions.sum(:amount)
    end

    starting_balance + incoming.to_d - outgoing.to_d
  end
end
