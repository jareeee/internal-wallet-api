require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe BalanceSnapshotWorker, type: :worker do
  around do |example|
    Sidekiq::Testing.inline! { example.run }
  end

  let(:currency) { 'IDR' }

  it 'creates a monthly snapshot for last month end with correct balance' do
    wallet = create(:user).create_wallet!

    # Two months ago: +1000
    deposit_old = Deposit.create!(target_wallet: wallet, amount: 1000, currency: currency)
    deposit_old.update!(created_at: 2.months.ago.end_of_month)

    # Last month: -200
    withdrawal_last = Withdrawal.create!(source_wallet: wallet, amount: 200, currency: currency)
    withdrawal_last.update!(created_at: 1.month.ago.end_of_month)

    # This month: +500 (should not be included)
    Deposit.create!(target_wallet: wallet, amount: 500, currency: currency)

    # Run worker
    BalanceSnapshotWorker.new.perform

    snapshot_date = Date.current.last_month.end_of_month
    snapshot = BalanceSnapshot.find_by(wallet: wallet, snapshot_date: snapshot_date)

    expect(snapshot).not_to be_nil
    expect(snapshot.snapshot_date).to eq(snapshot_date)
    expect(snapshot.balance_amount.to_d).to eq(800.to_d)
  end
end
