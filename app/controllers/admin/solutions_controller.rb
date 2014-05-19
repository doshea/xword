class Admin::SolutionsController < ApplicationController
  before_action :ensure_admin

  #GET /admin/solutions or admin_solutions_path
  def index
    @solutions = Solution.all.paginate(:page => params[:page])
  end

  #GET /admin/solutions/:id/edit or edit_admin_solution_path
  def edit
    @solution = Solution.find(params[:id])
  end

  #PATCH/PUT /admin/solutions/:id or admin_solution_path
  def update
    @solution = Solution.find(params[:id])
    @solution.update_attributes(params[:solution])
  end

  #DELETE /admin/solutions/:id or admin_solution_path
  def destroy
    @solution = Solution.find(params[:id])
    @solution.destroy
  end

end