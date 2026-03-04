class AdminController < ApplicationController
  before_action :ensure_admin
  
  #GET /admin/email or admin_email_path
  def email
  end

  #POST /admin/test_emails or admin_test_emails_path
  def test_emails
    sent = []
    errors = []
    if params[:reset_password]
      begin
        UserMailer.reset_password_email(@current_user).deliver_now
        sent << "reset_password"
      rescue StandardError => e
        errors << "reset_password: #{e.message}"
      end
    end
    if params[:nyt_upload_error]
      begin
        AdminMailer.nyt_upload_error_email.deliver_now
        sent << "nyt_upload_error"
      rescue StandardError => e
        errors << "nyt_upload_error: #{e.message}"
      end
    end
    if errors.any?
      redirect_to admin_email_path, flash: { error: "Delivery failed — #{errors.join('; ')}" }
    elsif sent.any?
      redirect_to admin_email_path, flash: { success: "Sent: #{sent.join(', ')}" }
    else
      redirect_to admin_email_path, flash: { warning: "No emails selected." }
    end
  end

  #GET /admin/clone_user or admin_cloning_tank_path
  def cloning_tank
  end

  def manual_nyt

  end

  def create_manual_nyt
    if params[:nyt_text]
      NytPuzzleImporter.import(JSON.parse(params[:nyt_text]))
      NytGithubRecorder.smart_record(params[:nyt_text])
      redirect_to admin_manual_nyt_path, flash: { success: 'NYT puzzle added.' }
    else
      redirect_to admin_manual_nyt_path, flash: { error: 'No NYT text provided.' }
    end
  rescue JSON::ParserError
    redirect_to admin_manual_nyt_path, flash: { error: 'Invalid JSON format.' }
  end

  #POST /admin/user_search or admin_user_search_path
  def user_search
    @users = User.admin_search(params[:query])
  end

  #POST /admin/clone_user or admin_clone_user_path
  def clone_user
    user = User.find params[:id]
    cookies.signed[:auth_token] = user.auth_token
    redirect_to root_path
  end

  #GET /admin/wine_comment or admin_wine_comment_path
  def wine_comment
  end

end