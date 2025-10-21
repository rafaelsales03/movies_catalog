class Comment < ApplicationRecord
  belongs_to :movie
  belongs_to :user, optional: true

  validates :name, :content, presence: true
end
