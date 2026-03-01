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
  # Replaced: alert_js (jquery_ujs JS response) → redirect (Turbo follows redirect) #
  def update
    if @solution.update(update_solution_params)
      redirect_to admin_solutions_path, notice: 'Solution updated.'
    else
      redirect_to edit_admin_solution_path(@solution), alert: 'Error updating solution.'
    end
  end

  #DELETE /admin/solutions/:id or admin_solution_path
  # Replaced: alert_js + destroy.js.erb DOM removal → redirect to index (Turbo follows) #
  def destroy
    if @solution.destroy
      redirect_to admin_solutions_path, notice: 'Solution deleted.'
    else
      redirect_to admin_solutions_path, alert: 'Error deleting solution.'
    end
  end

  private
  def update_solution_params
    params.require(:solution).permit(:lterrs, :is_complete, :team, :key)
  end

end