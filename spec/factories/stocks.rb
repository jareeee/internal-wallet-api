FactoryBot.define do
  factory :stock do
    symbol { "GOTO" }
    association :user
  end
end
