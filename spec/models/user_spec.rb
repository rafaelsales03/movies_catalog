require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      user = build(:user)
      expect(user).to be_valid
    end

    it 'is not valid without a name' do
      user = build(:user, name: nil)
      expect(user).not_to be_valid
      expect(user.errors.details[:name]).to include(error: :blank)
    end

    it 'is not valid without an email' do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
      expect(user.errors.details[:email]).to include(error: :blank)
    end

    it 'is not valid with a duplicate email' do
      create(:user, email: 'test@example.com')
      user = build(:user, email: 'test@example.com')
      expect(user).not_to be_valid
      # Devise might use :taken or :uniqueness
      expect(user.errors.details[:email]).to include(hash_including(error: :taken))
    end

    it 'is not valid without a password' do
      user = build(:user, password: nil)
      expect(user).not_to be_valid
      expect(user.errors.details[:password]).to include(error: :blank)
    end
  end

  describe 'associations' do
    it 'has many movies' do
      user = User.new
      expect(user).to respond_to(:movies)
    end
  end
end
