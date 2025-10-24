require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "should not save category without name" do
    category = Category.new
    assert_not category.save, "Saved the category without a name"
  end

  test "should not save duplicate category name" do
    Category.create!(name: "Ação")
    category = Category.new(name: "Ação")
    assert_not category.save, "Saved duplicate category name"
  end

  test "should save category with valid name" do
    category = Category.new(name: "Drama")
    assert category.save, "Failed to save valid category"
  end

  test "should capitalize category name before saving" do
    category = Category.create!(name: "ação e aventura")
    assert_equal "Ação E Aventura", category.name
  end

  test "should strip whitespace from name" do
    category = Category.create!(name: "  Comédia  ")
    assert_equal "Comédia", category.name
  end

  test "should have many movies" do
    category = categories(:action)
    assert_respond_to category, :movies
  end
end