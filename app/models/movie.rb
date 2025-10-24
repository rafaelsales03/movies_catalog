class Movie < ApplicationRecord
  belongs_to :user

  has_many :comments, dependent: :destroy
  has_and_belongs_to_many :categories

  validates :title, :synopsis, :year,  presence: true
end
