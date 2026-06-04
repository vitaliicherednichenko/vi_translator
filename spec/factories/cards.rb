FactoryBot.define do
  factory :card do
    front_text { "front" }
    back_text { "back" }
    association :user
    association :collection
    association :source_language, factory: :language
    association :target_language, factory: :language
  end
end
