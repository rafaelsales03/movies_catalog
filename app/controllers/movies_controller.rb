class MoviesController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_movie, only: %i[ show edit update destroy ]

  # GET /movies or /movies.json
  def index
    @movies = Movie.all
  end

  # GET /movies/1 or /movies/1.json
  def show
  end

  # GET /movies/new
  def new
    @movie = current_user.movies.build
  end

  # GET /movies/1/edit
  def edit
    authorize_movie_owner!
  end

  # POST /movies or /movies.json
  def create
    @movie = current_user.movies.build(movie_params)

    respond_to do |format|
      if @movie.save
        format.html { redirect_to @movie, notice: "Filme criado com sucesso." }
        format.json { render :show, status: :created, location: @movie }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /movies/1 or /movies/1.json
  def update
    authorize_movie_owner!

    respond_to do |format|
      if @movie.update(movie_params)
        format.html { redirect_to @movie, notice: "Filme atualizado com sucesso.", status: :see_other }
        format.json { render :show, status: :ok, location: @movie }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /movies/1 or /movies/1.json
  def destroy
    authorize_movie_owner!
    
    @movie.destroy!

    respond_to do |format|
      format.html { redirect_to movies_path, notice: "Filme deletado com sucesso.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_movie
      @movie = Movie.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def movie_params
      params.require(:movie).permit(:title, :synopsis, :year, :duration, :director)
    end

    def authorize_movie_owner!
      unless @movie.user == current_user
        redirect_to movies_path, alert: "Você não está autorizado a realizar esta ação."
      end
    end
end
