class Admin::SolutionsController < Admin::BaseController
  def index
    @solutions = Solution.includes(:crossword, :user).paginate(:page => params[:page])
  end

  private

  def resource_params
    params.require(:solution).permit(:letters, :is_complete, :team, :key)
  end
end
