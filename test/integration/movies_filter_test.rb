require "test_helper"

class MoviesFilterTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @category_action = Category.create!(name: "Ação")
    @category_drama = Category.create!(name: "Drama")
    @category_scifi = Category.create!(name: "Ficção Científica")

    @movie1 = @user.movies.create!(
      title: "Matrix",
      synopsis: "Um filme de ficção científica",
      year: 1999,
      duration: 136,
      director: "Wachowski"
    )
    @movie1.categories << [ @category_action, @category_scifi ]

    @movie2 = @user.movies.create!(
      title: "The Godfather",
      synopsis: "Um clássico sobre a máfia",
      year: 1972,
      duration: 175,
      director: "Coppola"
    )
    @movie2.categories << @category_drama

    @movie3 = @user.movies.create!(
      title: "Inception",
      synopsis: "Sonhos dentro de sonhos",
      year: 2010,
      duration: 148,
      director: "Nolan"
    )
    @movie3.categories << [ @category_action, @category_scifi ]

    @movie4 = @user.movies.create!(
      title: "Interstellar",
      synopsis: "Viagem espacial épica",
      year: 2014,
      duration: 169,
      director: "Nolan"
    )
    @movie4.categories << @category_scifi
  end

  test "should search by title" do
    get movies_path, params: { title: "Matrix" }
    assert_response :success
    assert_match /Matrix/, response.body
    assert_match /1 resultado encontrado/, response.body
  end

  test "should search by director" do
    get movies_path, params: { director: "Nolan" }
    assert_response :success
    assert_match /Inception/, response.body
    assert_match /Interstellar/, response.body
    assert_match /2 resultados encontrados/, response.body
  end

  test "should search by year" do
    get movies_path, params: { year: 1999 }
    assert_response :success
    assert_match /Matrix/, response.body
    assert_no_match /Godfather/, response.body
  end

  test "should search by category" do
    get movies_path, params: { category_id: @category_action.id }
    assert_response :success
    assert_match /Matrix/, response.body
    assert_match /Inception/, response.body
    assert_no_match /Godfather/, response.body
  end

  test "should filter by multiple categories" do
    get movies_path, params: {
      filter_categories: [ @category_action.id, @category_scifi.id ]
    }
    assert_response :success

    assert_match /Matrix/, response.body
    assert_match /Inception/, response.body
  end

  test "should filter by year range" do
    get movies_path, params: {
      year_from: 2000,
      year_to: 2015
    }
    assert_response :success
    assert_match /Inception/, response.body
    assert_match /Interstellar/, response.body
    assert_no_match /Matrix/, response.body
    assert_no_match /Godfather/, response.body
  end

  test "should filter by year from only" do
    get movies_path, params: { year_from: 2010 }
    assert_response :success
    assert_match /Inception/, response.body
    assert_match /Interstellar/, response.body
    assert_no_match /Matrix/, response.body
  end

  test "should filter by year to only" do
    get movies_path, params: { year_to: 2000 }
    assert_response :success
    assert_match /Matrix/, response.body
    assert_match /Godfather/, response.body
    assert_no_match /Inception/, response.body
  end

  test "should filter by multiple directors" do
    get movies_path, params: {
      filter_directors: [ "Nolan", "Coppola" ]
    }
    assert_response :success
    assert_match /Inception/, response.body
    assert_match /Interstellar/, response.body
    assert_match /Godfather/, response.body
    assert_no_match /Matrix/, response.body
  end

  test "should filter by single director in array" do
    get movies_path, params: {
      filter_directors: [ "Nolan" ]
    }
    assert_response :success
    assert_match /Inception/, response.body
    assert_match /Interstellar/, response.body
    assert_no_match /Matrix/, response.body
    assert_no_match /Godfather/, response.body
  end

  test "should combine simple search with advanced filters" do
    get movies_path, params: {
      title: "Inter",
      year_from: 2014
    }
    assert_response :success
    assert_match /Interstellar/, response.body
    assert_no_match /Inception/, response.body
  end

  test "should combine multiple advanced filters" do
    get movies_path, params: {
      filter_categories: [ @category_scifi.id ],
      filter_directors: [ "Nolan" ],
      year_from: 2010
    }
    assert_response :success
    assert_match /Inception/, response.body
    assert_match /Interstellar/, response.body
    assert_no_match /Matrix/, response.body
  end

  test "should combine all filters" do
    get movies_path, params: {
      title: "Inception",
      director: "Nolan",
      category_id: @category_action.id,
      filter_categories: [ @category_scifi.id ],
      year_from: 2000,
      year_to: 2020
    }
    assert_response :success
    assert_match /Inception/, response.body
    assert_no_match /Matrix/, response.body
  end

  test "should show active simple filters" do
    get movies_path, params: {
      title: "Matrix",
      director: "Wachowski",
      year: 1999
    }
    assert_response :success
    assert_match /Filtros ativos/, response.body
    assert_match /Título: Matrix/, response.body
    assert_match /Diretor: Wachowski/, response.body
    assert_match /Ano: 1999/, response.body
  end

  test "should show active advanced filters" do
    get movies_path, params: {
      filter_categories: [ @category_action.id, @category_scifi.id ],
      year_from: 2000,
      year_to: 2020,
      filter_directors: [ "Nolan" ]
    }
    assert_response :success
    assert_match /Filtros ativos/, response.body
    assert_match /Categorias \(filtro\)/, response.body
    assert_match /Período: de 2000 até 2020/, response.body
    assert_match /Diretores \(filtro\): Nolan/, response.body
  end

  test "should ignore empty filter arrays" do
    get movies_path, params: {
      filter_categories: [ "" ],
      filter_directors: [ "" ]
    }
    assert_response :success

    assert_match /Matrix/, response.body
    assert_match /Godfather/, response.body
    assert_match /Inception/, response.body
    assert_match /Interstellar/, response.body
  end

  test "should handle non-existent category in filter" do
    get movies_path, params: {
      filter_categories: [ 99999 ]
    }
    assert_response :success
    assert_match /Nenhum filme encontrado/, response.body
  end

  test "should be case insensitive for director filter" do
    get movies_path, params: {
      filter_directors: [ "NOLAN" ]
    }
    assert_response :success
    assert_match /Inception/, response.body
    assert_match /Interstellar/, response.body
  end

  test "should show no results message when filters match nothing" do
    get movies_path, params: {
      title: "NonExistent",
      year_from: 2030
    }
    assert_response :success
    assert_match /Nenhum filme encontrado/, response.body
    assert_select "a", text: "Ver todos os filmes"
  end

  test "should show clear filters button when filters are active" do
    get movies_path, params: { title: "Matrix" }
    assert_response :success
    assert_select "a", text: "Limpar todos os filtros"
  end

  test "should display total results count" do
    get movies_path, params: { filter_directors: [ "Nolan" ] }
    assert_response :success
    assert_match /2 resultados encontrados/, response.body
  end

  test "should handle invalid year format gracefully" do
    get movies_path, params: { year: "invalid" }
    assert_response :success

    assert_match /Matrix/, response.body
  end

  test "should handle year range where from is greater than to" do
    get movies_path, params: {
      year_from: 2020,
      year_to: 2010
    }
    assert_response :success

    assert_match /Nenhum filme encontrado/, response.body
  end

  test "should use distinct to avoid duplicate results" do
    get movies_path, params: {
      filter_categories: [ @category_action.id ]
    }
    assert_response :success

    matches = response.body.scan(/Matrix/).count
    assert_equal 1, matches, "Movie should appear only once in results"
  end

  test "should paginate filtered results" do
    7.times do |i|
      @user.movies.create!(
        title: "Nolan Film #{i}",
        synopsis: "Teste",
        year: 2020 + i,
        director: "Nolan"
      )
    end

    get movies_path, params: {
      filter_directors: [ "Nolan" ],
      per_page: 3
    }
    assert_response :success

    assert_select ".card", count: 3

    assert_select ".pagination"
  end

  test "should display advanced filters section collapsed by default" do
    get movies_path
    assert_response :success
    assert_select "#advancedFilters.collapse"
  end

  test "should display category checkboxes in advanced filters" do
    get movies_path
    assert_response :success
    assert_select "input[type=checkbox][name='filter_categories[]']", minimum: 3
  end

  test "should display director checkboxes in advanced filters" do
    get movies_path
    assert_response :success
    assert_select "input[type=checkbox][name='filter_directors[]']", minimum: 3
  end

  test "should display year range inputs" do
    get movies_path
    assert_response :success
    assert_select "input[name=year_from]"
    assert_select "input[name=year_to]"
  end

  test "should preserve filter values after search" do
    get movies_path, params: {
      title: "Matrix",
      year_from: 1990
    }
    assert_response :success
    assert_select "input[name=title][value='Matrix']"
    assert_select "input[name=year_from][value='1990']"
  end

  test "should preserve checkbox selections after search" do
    get movies_path, params: {
      filter_categories: [ @category_action.id.to_s ]
    }
    assert_response :success
    assert_select "input[name='filter_categories[]'][value='#{@category_action.id}'][checked]"
  end
end
