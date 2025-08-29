FactoryBot.define do
  factory :balance_snapshot do
    wallet { nil }
    balance_amount { "9.99" }
    snapshot_date { "2025-08-29" }
  end
end
