FactoryBot.define do
  factory :tag do
    sequence(:name) { |n| "Tag #{n}" }

    trait :formatted do
      name { "Clássico #{SecureRandom.hex(4)}" }
    end
  end
end
