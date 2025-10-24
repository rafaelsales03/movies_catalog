class Category < ApplicationRecord
  has_and_belongs_to_many :movies

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  before_save :capitalize_name

  scope :ordered, -> { order(:name) }

  private

  def capitalize_name
    self.name = name.strip.titleize
  end
end