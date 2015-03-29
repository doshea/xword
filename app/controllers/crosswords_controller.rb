class CrosswordsController < ApplicationController
  before_action :find_object, only: [:show, :team, :favorite, :unfavorite, :solution_choice]
  before_action :ensure_logged_in, only: [:create]
  before_action :ensure_owner_or_admin, only: [:edit, :update, :publish, :add_potential_word, :remove_potential_word]

  #GET /crosswords/:id or crossword_path
  def show
    if @current_user
      @solution = Solution.find_or_create_by(
        crossword_id: @crossword.id,
        user_id: @current_user.id,
        team: false
      )
      @solution.fill_letters
    end
    @cells = @crossword.cells.asc_indices
  end

  #GET /crosswords/:id/publish or publish_crossword_path
  def publish
    @crossword.publish! unless @crossword.published?
    redirect @crossword
  end

  #POST /crosswords/:id/team or create_team_crossword_path
  def create_team
    @crossword = Crossword.find(params[:id])
    if @crossword && @current_user
      preexisting_letters = @current_user.solutions.where(team: false, crossword_id: @crossword.id).first.try(:letters)
      @solution = Solution.new(
        crossword_id: @crossword.id,
        user_id: @current_user.id,
        letters: preexisting_letters || @crossword.letters.gsub(/[^_]/, ' ')
      )
      @solution.key = Solution.generate_unique_key
      @solution.team = true
      @solution.save
      redirect_to team_crossword_path(@crossword, @solution.key)
    else
      # Redirecto to some error page
    end
  end

  #GET /crosswords/:id/team/:key or team_crossword_path
  def team
    @solution = Solution.find_by_crossword_id_and_key(params[:id], params[:key])
    if @crossword && @solution
      @team = true
      @cells = @crossword.cells.asc_indices
      if @current_user
        SolutionPartnering.find_or_create_by(solution_id: @solution.id, user_id: @current_user.id) unless (@solution.user == @current_user)
      end
      render :show
    else
      #some sort of error
    end
  end

  #DELETE /crosswords/:id/remove_potential_word/:potential_word_id or remove_potential_word_crossword_path
  def remove_potential_word
    if @crossword
      @word = Word.find(params[:potential_word_id])
      @crossword.potential_words.delete(@word)
    else
      render nothing: true
    end
  end

  #POST /crosswords/:id/favorite or favorite_crossword_path
  def favorite
    if @crossword && @current_user
      if @current_user.favorites.include? @crossword
        alert_js('You have already favorited that crossword.')
      else
        if FavoritePuzzle.create(user_id: @current_user.id, crossword_id: @crossword.id)
          render :favorite_unfavorite
        end
      end
    end
  end

  #DELETE /crosswords/:id/favorite or favorite_crossword_path
  def unfavorite
    if @crossword && @current_user
      existing_favorite = FavoritePuzzle.find_by_user_id_and_crossword_id(@current_user.id, @crossword.id)
      if existing_favorite
        if existing_favorite.destroy
          render :favorite_unfavorite
        else
          alert_js('There was an error removing this crossword from favorites.')
        end
      else
        alert_js('That crossword is not in your favorites.')
      end
    end
  end

  #GET /crosswords/:id/solution_choice or solution_choice_crossword_path
  def solution_choice
    @solutions = Solution.where(user_id: @current_user.id, crossword_id: @crossword.id)
    @solutions += Solution.joins(:solution_partnerings).where(crossword_id: @crossword.id, solution_partnerings: {user_id: @current_user.id}).distinct
    @solutions.sort_by!{|x| [x.team ? 1 : 0, -x.percent_complete[:numerator], Time.current - x.updated_at]}

    if @solutions.count < 1
      redirect_to @crossword
    elsif @solutions.count == 1
      redirect_to @solutions.first
    end
  end

  #GET /crosswords/batch or batch_crosswords_path
  #TODO fix the batching links so they can't be too long. Right now the "Next 12" button can throw a long URI error
  def batch
    @crosswords = Crossword.find(params[:ids])
    @crosswords_remaining = @crosswords[Crossword.per_page..-1]
    @crosswords = @crosswords[0...Crossword.per_page]
  end

  private
  def create_crossword_params
    params.require(:crossword).permit(:title, :description, :rows, :cols)
  end
  def update_crossword_params
    params.require(:crossword).permit(:title, :description, :letters)
  end

end
