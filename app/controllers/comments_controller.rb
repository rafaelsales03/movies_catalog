class CommentsController < ApplicationController
  before_action :set_movie

  def create
    @comment = @movie.comments.build(comment_params)
    if user_signed_in?
      @comment.user = current_user
      @comment.name = current_user.name.presence || current_user.email
    end

    if @comment.save
      redirect_to movie_path(@movie), notice: "Comentário postado com sucesso."
    else
      redirect_to movie_path(@movie), alert: "Erro ao postar comentário: " + @comment.errors.full_messages.to_sentence
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
