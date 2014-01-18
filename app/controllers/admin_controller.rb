class AdminController < ApplicationController
  before_filter :ensure_admin
  def email

  end
  def test_emails
  end

  def cloning_tank
  end

  def user_search
    @users = User.admin_search(params[:query])
  end
  def clone_user
    user = User.find params[:id]
    cookies[:auth_token] = user.auth_token
    redirect_to root_path
  end

  def users
    @users = User.order(:created_at).paginate(:page => params[:page])
  end

  def crosswords
    @crosswords = Crossword.order(:created_at).paginate(:page => params[:page])
  end

  def words
    @words = Word.all.paginate(:page => params[:page])
  end

  def clues
    published_cw_ids = Crossword.published.pluck(:id)
    across_query = Clue.joins(:across_cells).where(cells: {crossword_id: published_cw_ids, is_across_start: true}).to_sql
    down_query = Clue.joins(:down_cells).where(cells: {crossword_id: published_cw_ids, is_down_start: true}).to_sql
    @clues = Clue.paginate_by_sql("(#{across_query}) UNION DISTINCT (#{down_query}) ORDER BY \"id\" ASC", page: params[:page])


    # @clues = Clue.joins(:across_cells).where(cells: {crossword_id: published_cw_ids, is_across_start: true}).paginate(:page => params[:page])
    # down_clues = Clue.joins(:down_cells).where(cells: {crossword_id: published_cw_ids, is_down_start: true})
    # @clues = Clue.all.paginate(:page => params[:page])
  end

  def comments
    @comments = Comment.all.paginate(:page => params[:page])
  end

end