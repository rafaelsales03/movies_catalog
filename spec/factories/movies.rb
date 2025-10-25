FactoryBot.define do
  factory :movie do
    association :user
    sequence(:title) { |n| "Movie Title #{n}" }
    synopsis { "A great movie synopsis." }
    year { Date.current.year - rand(1..30) }
    duration { rand(90..180) }
    director { "Director Name" }
  end
end
