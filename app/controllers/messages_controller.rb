class MessagesController < ApplicationController
  before_action :ensure_logged_in

  def create
    content = params[:content]
    return head :unprocessable_entity if content.blank?

    ActionCable.server.broadcast 'messages',
      message: content,
      user: @current_user.username
    head :ok
  end
end
