class Admin::SolutionsController < ApplicationController
  before_action :ensure_admin

  def index
    @solutions = Solution.all.paginate(:page => params[:page])
  end

  def edit
    @solution = Solution.find(params[:id])
  end

  def update
    @solution = Solution.find(params[:id])
    @solution.update_attributes(params[:solution])
  end

  def destroy
    @solution = Solution.find(params[:id])
    @solution.destroy
  end

end