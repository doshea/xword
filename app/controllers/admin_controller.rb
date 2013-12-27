class AdminController < ApplicationController
  before_filter :ensure_admin
  def email

  end

  def users
    @users = User.order(:created_at)
  end

  def crosswords
    @crosswords = Crossword.order(:created_at)
  end

  def words
    @words = Word.all
  end

  def clues
    @clues = Clue.all
  end

  def comments
    @comments = Comment.all
  end

end