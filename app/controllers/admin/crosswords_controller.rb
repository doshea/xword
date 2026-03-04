class Admin::CrosswordsController < Admin::BaseController
  skip_before_action :find_object
  before_action :find_object, only: [:edit, :update, :destroy, :generate_preview]

  def index
    @crosswords = Crossword.includes(:user).order(created_at: :asc).paginate(page: params[:page])
  end

  def generate_preview
    @crossword.generate_preview
    redirect_to edit_admin_crossword_path(@crossword), flash: { success: 'Preview generated.' }
  end

  private

  def resource_params
    params.require(:crossword).permit(:title, :rows, :cols, :circled, :description, :letters)
  end
end
