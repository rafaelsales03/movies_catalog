require 'rails_helper'

RSpec.describe Tag, type: :model do
  describe 'validations' do
   it 'is not valid without a name' do
      tag = build(:tag, name: nil)
      expect(tag).not_to be_valid
      expect(tag.errors.details[:name]).to include(error: :blank)
    end

    it 'is not valid with a duplicate name (case-insensitive)' do
      create(:tag, name: "Clássico")
      tag = build(:tag, name: "clássico")
      expect(tag).not_to be_valid
      expect(tag.errors.details[:name]).to include(error: :taken, value: "clássico")
    end

    it 'is valid with a unique name' do
      tag = build(:tag, name: "Independente")
      expect(tag).to be_valid
    end

    it 'is not valid with a name shorter than 2 characters' do
      tag = build(:tag, name: "A")
      expect(tag).not_to be_valid
      expect(tag.errors.details[:name]).to include(error: :too_short, count: 2)
    end

    it 'is not valid with a name longer than 50 characters' do
      tag = build(:tag, name: "A" * 51)
      expect(tag).not_to be_valid
      expect(tag.errors.details[:name]).to include(error: :too_long, count: 50)
    end
  end

  describe 'callbacks' do
    it 'normalizes the name before saving (capitalize words)' do
      tag = create(:tag, name: "baseado em fatos reais")
      expect(tag.name).to eq("Baseado Em Fatos Reais")
    end

    it 'strips whitespace from name before saving' do
      tag = create(:tag, name: "  Oscar  ")
      expect(tag.name).to eq("Oscar")
    end
  end

  describe 'associations' do
    it 'has and belongs to many movies' do
      tag = Tag.new
      expect(tag).to respond_to(:movies)
    end
  end

  describe 'scopes' do
    it '.ordered returns tags ordered by name' do
      tag_z = create(:tag, name: "Zebra")
      tag_a = create(:tag, name: "Alpha")
      tag_b = create(:tag, name: "Beta")

      expect(Tag.ordered).to eq([ tag_a, tag_b, tag_z ])
    end
  end

  describe '#usage_count' do
    it 'returns the number of movies associated with the tag' do
      tag = create(:tag)
      user = create(:user)
      movie1 = create(:movie, user: user, tags: [ tag ])
      movie2 = create(:movie, user: user, tags: [ tag ])
      create(:movie, user: user)

      expect(tag.usage_count).to eq(2)
    end
  end
end
