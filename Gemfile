source "https://rubygems.org"

gem "rails", "~> 8.1.0"
gem "propshaft"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"

gem "tzinfo-data", platforms: %i[ windows jruby ]

gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

gem "bootsnap", require: false
gem "devise"
gem "kaminari"

gem "kamal", require: false

gem "thruster", require: false

gem "image_processing", "~> 1.2"

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  gem "brakeman", require: false

  gem "rubocop-rails-omakase", require: false

  gem "rspec-rails", "~> 6.0"
  gem "factory_bot_rails"
end

group :development do
  gem "web-console"
  gem "letter_opener"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"

  gem "database_cleaner-active_record"
end
