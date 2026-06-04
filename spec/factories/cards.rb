FactoryBot.define do
  factory :card do
    front_text { "MyText" }
    back_text { "MyText" }
    user { nil }
    collection { nil }
    source_language { nil }
    target_language { nil }
  end
end
