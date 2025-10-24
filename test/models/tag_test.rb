require "test_helper"

class TagTest < ActiveSupport::TestCase
  test "should not save tag without name" do
    tag = Tag.new
    assert_not tag.save, "Saved the tag without a name"
  end

  test "should not save duplicate tag name" do
    Tag.create!(name: "Clássico")
    tag = Tag.new(name: "Clássico")
    assert_not tag.save, "Saved duplicate tag name"
  end

  test "should save tag with valid name" do
    tag = Tag.new(name: "Independente")
    assert tag.save, "Failed to save valid tag"
  end

  test "should normalize tag name before saving" do
    tag = Tag.create!(name: "baseado em fatos reais")
    assert_equal "Baseado Em Fatos Reais", tag.name
  end

  test "should strip whitespace from name" do
    tag = Tag.create!(name: "  Oscar  ")
    assert_equal "Oscar", tag.name
  end

  test "should not save tag with name shorter than 2 characters" do
    tag = Tag.new(name: "A")
    assert_not tag.save, "Saved tag with name too short"
  end

  test "should not save tag with name longer than 50 characters" do
    tag = Tag.new(name: "A" * 51)
    assert_not tag.save, "Saved tag with name too long"
  end

  test "should have many movies" do
    tag = tags(:classic)
    assert_respond_to tag, :movies
  end

  test "should return usage count" do
    tag = tags(:classic)
    user = users(:one)

    movie1 = user.movies.create!(
      title: "Test Movie 1",
      synopsis: "Test",
      year: 2020
    )
    movie1.tags << tag

    movie2 = user.movies.create!(
      title: "Test Movie 2",
      synopsis: "Test",
      year: 2021
    )
    movie2.tags << tag

    assert_equal 2, tag.usage_count
  end

  test "should order tags alphabetically" do
    Tag.create!(name: "Zebra")
    Tag.create!(name: "Alpha")
    Tag.create!(name: "Beta")

    ordered = Tag.ordered.pluck(:name)
    assert_equal ordered, ordered.sort
  end

  test "should handle case insensitive uniqueness" do
    Tag.create!(name: "Clássico")
    tag = Tag.new(name: "CLÁSSICO")
    assert_not tag.save, "Saved duplicate tag with different case"
  end
end
