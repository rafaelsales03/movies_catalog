class Movie < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_and_belongs_to_many :categories

  validates :title, :synopsis, :year, presence: true
  validates :year, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1888,
    less_than_or_equal_to: -> { Date.current.year + 5 }
  }, allow_blank: true
  validates :duration, numericality: {
    only_integer: true,
    greater_than: 0
  }, allow_blank: true

  scope :by_title, ->(title) {
    where("LOWER(title) LIKE ?", "%#{sanitize_sql_like(title.to_s.downcase)}%") if title.present?
  }

  scope :by_director, ->(director) {
    where("LOWER(director) LIKE ?", "%#{sanitize_sql_like(director.to_s.downcase)}%") if director.present?
  }

  scope :by_year, ->(year) {
    where(year: year) if year.present?
  }

  scope :by_category, ->(category_id) {
    joins(:categories).where(categories: { id: category_id }).distinct if category_id.present?
  }


  scope :by_categories, ->(category_ids) {
    if category_ids.present? && category_ids.is_a?(Array)
      clean_ids = category_ids.reject(&:blank?).map(&:to_i)
      if clean_ids.any?
        movie_ids = joins(:categories)
                      .where(categories: { id: clean_ids })
                      .select("movies.id")
                      .group("movies.id")
                      .having("COUNT(DISTINCT categories.id) = ?", clean_ids.size)
                      .pluck(:id)

        where(id: movie_ids) if movie_ids.any?
      end
    end
  }

  scope :by_year_range, ->(year_from, year_to) {
    query = all
    query = query.where("year >= ?", year_from) if year_from.present?
    query = query.where("year <= ?", year_to) if year_to.present?
    query
  }

  scope :by_directors, ->(directors) {
    if directors.present? && directors.is_a?(Array)
      clean_directors = directors.reject(&:blank?).map(&:downcase)
      if clean_directors.any?
        conditions = clean_directors.map { "LOWER(director) LIKE ?" }.join(" OR ")
        values = clean_directors.map { |d| "%#{sanitize_sql_like(d)}%" }
        where(conditions, *values)
      end
    end
  }

  def self.simple_search(params)
    movies = all
    movies = movies.by_title(params[:title])
    movies = movies.by_director(params[:director])
    movies = movies.by_year(params[:year])
    movies = movies.by_category(params[:category_id])
    movies.order(created_at: :desc)
  end

  def self.advanced_search(params)
    movies = all
    movies = movies.by_title(params[:title])
    movies = movies.by_director(params[:director])
    movies = movies.by_year(params[:year])
    movies = movies.by_category(params[:category_id])
    movies = movies.by_categories(params[:filter_categories])
    movies = movies.by_year_range(params[:year_from], params[:year_to])
    movies = movies.by_directors(params[:filter_directors])
    movies.order(created_at: :desc)
  end

  def self.unique_directors
    where.not(director: [ nil, "" ])
      .distinct
      .pluck(:director)
      .sort
  end
end
