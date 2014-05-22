class Admin::SolutionsController < ApplicationController
  before_action :ensure_admin
  before_action :find_solution, only: [:edit, :update, :destroy]

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
    if @solution.update_attributes(params[:solution])
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

  def find_solution
    @solution = Solution.find(params[:id])
    rescue ActiveRecord::RecordNotFound
    redirect_to :back, flash: {error: 'Sorry, that solution could not be found.'}
  end

end