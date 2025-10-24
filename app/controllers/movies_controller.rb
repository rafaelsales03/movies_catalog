class MoviesController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_movie, only: %i[show edit update destroy]

  rescue_from ActiveRecord::RecordNotFound, with: :movie_not_found

  # GET /movies
  def index
    @categories = Category.ordered
    @all_directors = Movie.unique_directors

    @movies = Movie.includes(:categories, :tags, poster_attachment: :blob)
                   .advanced_search(filter_params)
                   .page(params[:page])
                   .per(params[:per_page] || 6)

    @search_performed = filter_params.values.any? do |value|
      if value.is_a?(Array)
        value.reject(&:blank?).any?
      else
        value.present?
      end
    end

    @total_results = @movies.total_count
    @active_filters = build_active_filters
  end

  # GET /movies/1
  def show
    @comment = Comment.new
  end

  # GET /movies/new
  def new
    @movie = current_user.movies.build
    @categories = Category.ordered
  end

  # GET /movies/1/edit
  def edit
    authorize_movie_owner!
    @categories = Category.ordered
  end

  # POST /movies
  def create
    @movie = current_user.movies.build(movie_params)

    respond_to do |format|
      if @movie.save
        format.html { redirect_to @movie, notice: "Filme criado com sucesso." }
        format.json { render :show, status: :created, location: @movie }
      else
        @categories = Category.ordered
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /movies/1
  def update
    authorize_movie_owner!

    if params[:movie][:remove_poster] == "1"
      @movie.poster.purge
    end

    respond_to do |format|
      if @movie.update(movie_params.except(:remove_poster))
        format.html { redirect_to @movie, notice: "Filme atualizado com sucesso.", status: :see_other }
        format.json { render :show, status: :ok, location: @movie }
      else
        @categories = Category.ordered
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /movies/1
  def destroy
    authorize_movie_owner!
    @movie.destroy!

    respond_to do |format|
      format.html { redirect_to movies_path, notice: "Filme deletado com sucesso.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  def set_movie
    if user_signed_in? && (action_name != "show")
      @movie = current_user.movies.includes(poster_attachment: :blob).find(params[:id])
    else
      @movie = Movie.includes(:categories, :tags, :comments, poster_attachment: :blob).find(params[:id])
    end
  end

  def movie_not_found
    redirect_to movies_path, alert: "Filme não encontrado ou você não tem permissão para acessá-lo."
  end

  def movie_params
    params.require(:movie).permit(
      :title,
      :synopsis,
      :year,
      :duration,
      :director,
      :tag_list,
      :poster,
      :remove_poster,
      category_ids: []
    )
  end

  def filter_params
    params.permit(
      :title,
      :director,
      :year,
      :category_id,
      :year_from,
      :year_to,
      filter_categories: [],
      filter_directors: [],
      filter_tags: []
    )
  end

  def authorize_movie_owner!
    unless @movie.user == current_user
      redirect_to movies_path, alert: "Você não está autorizado a realizar esta ação."
    end
  end

  def build_active_filters
    filters = []

    filters << "Título: #{params[:title]}" if params[:title].present?
    filters << "Diretor: #{params[:director]}" if params[:director].present?
    filters << "Ano: #{params[:year]}" if params[:year].present?

    if params[:category_id].present?
      category = @categories.find_by(id: params[:category_id])
      filters << "Categoria: #{category.name}" if category
    end

    if params[:filter_categories].present?
      selected = params[:filter_categories].reject(&:blank?)
      if selected.any?
        category_names = @categories.where(id: selected).pluck(:name).join(", ")
        filters << "Categorias (filtro): #{category_names}"
      end
    end

    if params[:filter_tags].present?
      selected = params[:filter_tags].reject(&:blank?)
      if selected.any?
        tag_names = Tag.where(id: selected).pluck(:name).join(", ")
        filters << "Tags: #{tag_names}"
      end
    end

    if params[:year_from].present? || params[:year_to].present?
      year_range = []
      year_range << "de #{params[:year_from]}" if params[:year_from].present?
      year_range << "até #{params[:year_to]}" if params[:year_to].present?
      filters << "Período: #{year_range.join(' ')}"
    end

    if params[:filter_directors].present?
      selected = params[:filter_directors].reject(&:blank?)
      if selected.any?
        filters << "Diretores (filtro): #{selected.join(', ')}"
      end
    end

    filters
  end
end
