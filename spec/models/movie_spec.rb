require 'rails_helper'

RSpec.describe Movie, type: :model do
  let(:user) { create(:user) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      movie = build(:movie, user: user)
      expect(movie).to be_valid
    end

    it 'is not valid without a title' do
      movie = build(:movie, user: user, title: nil)
      expect(movie).not_to be_valid
      expect(movie.errors.details[:title]).to include(error: :blank)
    end

    it 'is not valid without a synopsis' do
      movie = build(:movie, user: user, synopsis: nil)
      expect(movie).not_to be_valid
      expect(movie.errors.details[:synopsis]).to include(error: :blank)
    end

    it 'is not valid without a year' do
      movie = build(:movie, user: user, year: nil)
      expect(movie).not_to be_valid
      expect(movie.errors.details[:year]).to include(error: :blank)
    end

    it 'is not valid with a year before 1888' do
      movie = build(:movie, user: user, year: 1887)
      expect(movie).not_to be_valid
      expect(movie.errors.details[:year]).to include(hash_including(error: :greater_than_or_equal_to, count: 1888))
    end

    it 'is not valid with a duration that is not a positive integer' do
      movie = build(:movie, user: user, duration: 0)
      expect(movie).not_to be_valid
      expect(movie.errors.details[:duration]).to include(hash_including(error: :greater_than, count: 0))
    end
  end

  describe 'associations' do
    it 'belongs to user' do
      movie = Movie.new
      expect(movie).to respond_to(:user)
    end

    it 'has many comments' do
      movie = Movie.new
      expect(movie).to respond_to(:comments)
    end

    it 'has and belongs to many categories' do
      movie = Movie.new
      expect(movie).to respond_to(:categories)
    end

    it 'has and belongs to many tags' do
      movie = Movie.new
      expect(movie).to respond_to(:tags)
    end

    it 'has one attached poster' do
       movie = Movie.new
       expect(movie).to respond_to(:poster)
    end
  end
end
