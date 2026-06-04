FactoryBot.define do
  factory :collection do
    name { "My Collection" }
    description { "A description" }
    association :user
    association :language
  end
end
