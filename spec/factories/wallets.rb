FactoryBot.define do
  factory :wallet do
    association :walletable, factory: :user
    currency { 'IDR' }
  end
end
