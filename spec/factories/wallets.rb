FactoryBot.define do
  factory :wallet do
    association :walletable, factory: :user
  end
end
