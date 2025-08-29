FactoryBot.define do
  factory :transaction do
    transaction_type { "MyString" }
    amount { "9.99" }
    currency { "MyString" }
    source_wallet { nil }
    target_wallet { nil }
    description { "MyText" }
  end
end
