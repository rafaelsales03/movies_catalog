class CategoriesController < ApplicationController
  before_action :set_category, only: %i[edit update destroy]

  # GET /categories
  def index
    @categories = Category.ordered.page(params[:page]).per(20)
  end

  # GET /categories/new
  def new
    @category = Category.new
  end

  # GET /categories/:id/edit
  def edit
  end

  # POST /categories
  def create
    @category = Category.new(category_params)

    if @category.save
      redirect_to categories_path, notice: "Categoria criada com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /categories/:id
  def update
    if @category.update(category_params)
      redirect_to categories_path, notice: "Categoria atualizada com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /categories/:id
  def destroy
    @category.destroy!
    redirect_to categories_path, notice: "Categoria excluída com sucesso.", status: :see_other
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name)
  end
end