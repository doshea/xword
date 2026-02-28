class Admin::SolutionsController < ApplicationController
  before_action :ensure_admin
  before_action :find_object, only: [:edit, :update, :destroy]

  #GET /admin/solutions or admin_solutions_path
  def index
    @solutions = Solution.all.paginate(:page => params[:page])
  end

  #GET /admin/solutions/:id/edit or edit_admin_solution_path
  def edit
  end

  #PATCH/PUT /admin/solutions/:id or admin_solution_path
  # AJAX #
  def update
    if @solution.update(update_solution_params)
      alert_js('SUCCESS solution updated.')
    else
      alert_js('!!!ERROR updating solution!!!')
    end
  end

  #DELETE /admin/solutions/:id or admin_solution_path
  # AJAX #
  def destroy
    if @solution.destroy
      alert_js('SUCCESS solution deleted.')
    else
      alert_js('!!!ERROR deleting solution!!!')
    end
  end

  private
  def update_solution_params
    params.require(:solution).permit(:lterrs, :is_complete, :team, :key)
  end

end