FactoryBot.define do
  factory :comment do
    association :movie
    association :user, optional: true
    content { "This is a comment." }

    trait :guest_comment do
      user { nil }
      name { "Guest User" }
    end
  end
end
