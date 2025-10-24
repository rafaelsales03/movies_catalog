class Movie < ApplicationRecord
  belongs_to :user

  has_many :comments, dependent: :destroy
  has_and_belongs_to_many :categories

  validates :title, :synopsis, :year,  presence: true

  scope :by_title, ->(title) { where("LOWER(title) LIKE ?", "%#{title.downcase}%") if title.present? }
  scope :by_director, ->(director) { where("LOWER(director) LIKE ?", "%#{director.downcase}%") if director.present? }
  scope :by_year, ->(year) { where(year: year) if year.present? }
  scope :by_category, ->(category_id) { joins(:categories).where(categories: { id: category_id }) if category_id.present? }
end
