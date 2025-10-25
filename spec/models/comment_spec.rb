require 'rails_helper'

RSpec.describe Comment, type: :model do
  let(:user) { create(:user) }
  let(:movie) { create(:movie, user: user) }

  describe 'validations' do
    it 'is valid with content, movie and user' do
      comment = build(:comment, movie: movie, user: user)
      expect(comment).to be_valid
    end

    it 'is valid with content, movie and guest name (no user)' do
      comment = build(:comment, :guest_comment, movie: movie)
      expect(comment).to be_valid
    end

    it 'is not valid without content' do
      comment = build(:comment, movie: movie, user: user, content: nil)
      expect(comment).not_to be_valid
      expect(comment.errors.details[:content]).to include(error: :blank)
    end

    it 'is not valid without a movie' do
      comment = build(:comment, movie: nil, user: user)
      expect(comment).not_to be_valid
      expect(comment.errors.details[:movie]).to include(error: :blank)
    end

    it 'is not valid without a user or a guest name' do
      comment = build(:comment, movie: movie, user: nil, name: nil)
      expect(comment).not_to be_valid
      expect(comment.errors.details[:name]).to include(error: :blank)
    end
  end

  describe 'associations' do
    it 'belongs to movie' do
      comment = Comment.new
      expect(comment).to respond_to(:movie)
    end

    it 'belongs to user (optional)' do
      comment = Comment.new
      expect(comment).to respond_to(:user)
    end
  end
end
