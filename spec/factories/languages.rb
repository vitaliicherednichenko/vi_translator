FactoryBot.define do
  factory :language do
    sequence(:name) { |n| "Language #{n}" }
    sequence(:code) { |n| ("aa".."zz").to_a[n] } # unique two-letter codes
    native_name { "Native name" }
  end
end
