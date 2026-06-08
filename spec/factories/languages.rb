FactoryBot.define do
  factory :language do
    sequence(:name) { |n| "Language #{n}" }
    sequence(:code) { |n| ("aa".."zz").to_a[n % 676] }
    native_name { "Native name" }
  end
end
