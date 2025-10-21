class Movie < ApplicationRecord
  belongs_to :user

  has_many :comments, dependent: :destroy

  validates :title, :synopsis, :year,  presence: true
end
