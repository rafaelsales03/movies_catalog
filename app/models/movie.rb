class Movie < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_and_belongs_to_many :categories
  has_and_belongs_to_many :tags
  has_one_attached :poster

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
  validate :poster_format

  attr_accessor :tag_list, :remove_poster

  before_validation :clear_poster_if_needed

  after_save :sync_tags

  scope :by_title, ->(title) {
    where("LOWER(title) LIKE ?", "%#{sanitize_sql_like(title.to_s.downcase)}%") if title.present?
  }

  scope :by_director, ->(director) {
    where("LOWER(director) LIKE ?", "%#{sanitize_sql_like(director.to_s.downcase)}%") if director.present?
  }

  scope :by_year, ->(year) {
    where(year: year.to_i) if year.present? && year.to_i > 0
  }


  scope :by_category, ->(category_id) {
    joins(:categories).where(categories: { id: category_id }).distinct if category_id.present?
  }

  scope :by_categories, ->(category_ids) {
    clean_ids = Array(category_ids).reject(&:blank?).map(&:to_i)
    if clean_ids.any?
      movie_ids = joins(:categories)
                    .where(categories: { id: clean_ids })
                    .group("movies.id")
                    .having("COUNT(DISTINCT categories.id) = ?", clean_ids.size)
                    .pluck(:id)
      movie_ids.any? ? where(id: movie_ids) : none
    end
  }


  scope :by_year_range, ->(year_from, year_to) {
    query = all
    from = year_from.to_i if year_from.present?
    to = year_to.to_i if year_to.present?
    query = query.where("year >= ?", from) if from && from > 0
    query = query.where("year <= ?", to) if to && to > 0
    query
  }

  scope :by_directors, ->(directors) {
    clean_directors = Array(directors).reject(&:blank?).map(&:downcase)
    if clean_directors.any?
      conditions = clean_directors.map { |d| sanitize_sql_array([ "LOWER(director) LIKE ?", "%#{sanitize_sql_like(d)}%" ]) }.join(" OR ")
      where(conditions)
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
    movies = movies.by_title(params[:title])                     if params[:title].present?
    movies = movies.by_director(params[:director])               if params[:director].present?
    movies = movies.by_year(params[:year])                       if params[:year].present?
    movies = movies.by_category(params[:category_id])            if params[:category_id].present?
    movies = movies.merge(by_categories(params[:filter_categories])) if params[:filter_categories].present?
    movies = movies.by_year_range(params[:year_from], params[:year_to]) if params[:year_from].present? || params[:year_to].present?
    movies = movies.merge(by_directors(params[:filter_directors]))   if params[:filter_directors].present?

    movies.order(created_at: :desc).distinct
  end


  def self.unique_directors
    where.not(director: [ nil, "" ])
      .distinct
      .pluck(:director)
      .sort
  end

  def tag_list
    @tag_list || tags.map(&:name).join(", ")
  end

  private

  def clear_poster_if_needed
    poster.purge if remove_poster == "1"
  end


  def sync_tags
    return unless defined?(@tag_list) && @tag_list

    current_tags = tags.map(&:name)
    new_tags = @tag_list.split(",").map(&:strip).reject(&:blank?).uniq.map do |tag_name|
      tag_name.strip.split.map(&:capitalize).join(" ")
    end

    tags_to_remove = current_tags - new_tags
    if tags_to_remove.any?
      tags.where(name: tags_to_remove).destroy_all
    end

    tags_to_add = new_tags - current_tags
    tags_to_add.each do |tag_name|
      tag = Tag.find_or_create_by(name: tag_name)
      self.tags << tag unless self.tags.include?(tag)
    end
  end


  def poster_format
    return unless poster.attached?

    unless poster.content_type.in?(%w[image/jpeg image/jpg image/png image/webp])
      errors.add(:poster, :content_type)
    end

    unless poster.byte_size <= 5.megabytes
      errors.add(:poster, :size)
    end
  end
end
