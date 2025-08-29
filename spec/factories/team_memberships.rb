FactoryBot.define do
  factory :team_membership do
    user { nil }
    team { nil }
    role { "MyString" }
  end
end
