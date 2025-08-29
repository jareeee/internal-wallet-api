class BalanceSnapshotWorker
  include Sidekiq::Worker

  def perform
    snapshot_date = Date.current.last_month.end_of_month

    Wallet.find_each do |wallet|
      incoming = wallet.incoming_transactions.where("created_at <= ?", snapshot_date.end_of_day).sum(:amount)
      outgoing = wallet.outgoing_transactions.where("created_at <= ?", snapshot_date.end_of_day).sum(:amount)

      balance = incoming.to_d - outgoing.to_d

      snapshot = BalanceSnapshot.find_or_initialize_by(wallet_id: wallet.id, snapshot_date: snapshot_date)
      snapshot.balance_amount = balance
      snapshot.save!
    end
  end
end
