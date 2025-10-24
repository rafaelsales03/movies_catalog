class CreateJoinTableMoviesCategories < ActiveRecord::Migration[8.0]
  def change
    create_join_table :movies, :categories do |t|
      t.index :movie_id
      t.index :category_id
      t.index [:movie_id, :category_id], unique: true
    end
  end
end