class CreateController < ApplicationController

  #GET /create/dashboard or create_dashboard_path
  def dashboard
    @owned_puzzles = @current_user.crosswords
    if @owned_puzzles.any?
      @unpublished = @owned_puzzles.unpublished
      @published = @owned_puzzles.published
    end
  end
end