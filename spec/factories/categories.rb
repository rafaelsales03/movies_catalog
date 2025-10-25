FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "Category #{n}" }

    trait :formatted do
      name { "Ação #{SecureRandom.hex(4)}" }
    end
  end
end
