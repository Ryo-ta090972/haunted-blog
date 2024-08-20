# frozen_string_literal: true

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  before_action :set_current_user_blog, only: %i[edit update destroy]
  before_action :set_accessible_blog, only: %i[show]

  def index
    @blogs = Blog.search(params[:term]).published.default_order
  end

  def show; end

  def new
    @blog = Blog.new
  end

  def edit; end

  def create
    @blog = current_user.blogs.new(blog_params)

    if @blog.save
      redirect_to blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @blog.update(blog_params)
      redirect_to blog_url(@blog), notice: 'Blog was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @blog.destroy!

    redirect_to blogs_url, notice: 'Blog was successfully destroyed.', status: :see_other
  end

  private

  def blog_params
    blog_attributes = %i[title content secret]
    blog_attributes << :random_eyecatch if current_user.premium?
    params.require(:blog).permit(blog_attributes)
  end

  def set_current_user_blog
    @blog = current_user.blogs.find(params[:id])
  end

  def set_accessible_blog
    blog = Blog.find(params[:id])
    is_current_user_blog = user_signed_in? && blog.user_id == current_user.id
    @blog = is_current_user_blog ? blog : Blog.find_by!(id: params[:id], secret: false)
  end
end
