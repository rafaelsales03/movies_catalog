class Movie < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
  validates :synopsis, presence: true
  validates :year, presence: true, numericality: { only_integer: true }
end
