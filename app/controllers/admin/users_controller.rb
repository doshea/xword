class Admin::UsersController < Admin::BaseController
  def index
    @users = User.order(:created_at).paginate(:page => params[:page])
  end

  private

  def resource_params
    params.require(:user).permit(:username, :email, :image, :remote_image_url, :is_admin, :location)
  end
end
