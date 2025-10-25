require 'rails_helper'

RSpec.describe Category, type: :model do
  describe 'validations' do
   it 'is not valid without a name' do
      category = build(:category, name: nil)
      expect(category).not_to be_valid
      expect(category.errors.details[:name]).to include(error: :blank)
    end

    it 'is not valid with a duplicate name (case-insensitive)' do
      create(:category, name: "Ação")
      category = build(:category, name: "ação")
      expect(category).not_to be_valid
      expect(category.errors.details[:name]).to include(error: :taken, value: "ação")
    end

    it 'is valid with a unique name' do
      category = build(:category, name: "Drama")
      expect(category).to be_valid
    end
  end

  describe 'callbacks' do
    it 'capitalizes the name before saving' do
      category = create(:category, name: "ação e aventura")
      expect(category.name).to eq("Ação E Aventura")
    end

    it 'strips whitespace from name before saving' do
      category = create(:category, name: "  Comédia  ")
      expect(category.name).to eq("Comédia")
    end
  end

  describe 'associations' do
    it 'has and belongs to many movies' do
      category = Category.new
      expect(category).to respond_to(:movies)
    end
  end

  describe 'scopes' do
    it '.ordered returns categories ordered by name' do
      category_c = create(:category, name: "Comédia")
      category_a = create(:category, name: "Ação")
      category_d = create(:category, name: "Drama")

      expect(Category.ordered).to eq([ category_a, category_c, category_d ])
    end
  end
end
