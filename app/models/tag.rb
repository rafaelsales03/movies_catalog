class Tag < ApplicationRecord
  has_and_belongs_to_many :movies

  validates :name, presence: true,
                   uniqueness: { case_sensitive: false },
                   length: { minimum: 2, maximum: 50 }

  before_save :normalize_name

  scope :ordered, -> { order(:name) }

  def usage_count
    movies.count
  end

  private

  def normalize_name
    self.name = name.strip.split.map(&:capitalize).join(" ")
  end
end
