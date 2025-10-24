class CommentsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :create ]

  before_action :set_movie

  def create
    @comment = @movie.comments.build(comment_params)

    if user_signed_in?
      @comment.user = current_user
      @comment.name = current_user.name.presence || t("activerecord.attributes.user.anonymous", default: "Usuário sem nome")
    end

    if @comment.save
      redirect_to movie_path(@movie), notice: t("flash.comments.created")
    else
      flash.now[:alert] = t("flash.comments.error")
      render "movies/show", status: :unprocessable_entity
    end
  end

  private

  def set_movie
    @movie = Movie.find(params[:movie_id])
  end

  def comment_params
    params.require(:comment).permit(:name, :content)
  end
end
