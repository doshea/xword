class CrosswordsController < ApplicationController
  before_action :find_crossword, only: [:show, :team, :favorite, :unfavorite, :solution_choice]
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

  #GET /crosswords/new or new_crossword_path
  def new
    @crossword = Crossword.new
  end

  #POST /crosswords or crosswords_path
  def create
    @crossword = Crossword.new(params[:crossword])
    @crossword.user = @current_user
    if @crossword.save
      @crossword.link_cells_to_neighbors
      redirect_to edit_crossword_path(@crossword)
    else
      render :new, flash: {error: 'There was a problem saving your crossword.'}
    end
  end

  #GET /crosswords/:id/edit or edit_crossword_path
  def edit
    if @crossword.published?
      redirect_to @crossword, flash: {secondary: 'Sorry, that puzzle has been published and cannot be further edited.'}
    else
      @cells = @crossword.cells.asc_indices
      @across_cells = @crossword.across_start_cells.includes(:across_clue).asc_indices
      @down_cells = @crossword.down_start_cells.includes(:across_clue).asc_indices
      @across_clues = Clue.joins(:across_cells).where(cells: {crossword_id: @crossword.id}).order('cells.index')
      @down_clues = Clue.joins(:down_cells).where(cells: {crossword_id: @crossword.id}).order('cells.index')
      @potential_words = @crossword.potential_words.desc_length
    end
  end

  #PATCH/PUT /crosswords/:id or crossword_path
  def update
    crossword.update_attributes(params[:crossword])
    render nothing: true
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

  #POST /crosswords/:id/add_potential_word or add_potential_word_crossword_path
  def add_potential_word
    if @crossword
      word_content = params[:word].upcase
      @word = Word.find_or_create_by_content(word_content)
      @new_word = !@crossword.potential_words.include?(@word)
      if @new_word
        @added = true
        @crossword.potential_words << @word
      end
    else
      render nothing: true
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
    unless @crossword.published
      redirect_to edit_crossword_path(@crossword)
    else

      @solutions = Solution.where(user_id: @current_user.id, crossword_id: @crossword.id)
      @solutions += Solution.joins(:solution_partnerings).where(crossword_id: @crossword.id, solution_partnerings: {user_id: @current_user.id}).distinct
      @solutions.sort_by!{|x| [x.team ? 1 : 0, -x.percent_complete[:numerator], Time.current - x.updated_at]}

      if @solutions.count < 1
        redirect_to @crossword
      elsif @solutions.count == 1
        redirect_to @solutions.first
      end
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

  def ensure_owner_or_admin
    @crossword = Crossword.find(params[:id])
    if !(@current_user.is_admin or @current_user == @crossword.user)
      redirect_to :back, flash: {warning: 'You do not own that crossword.'}
    end
  end

  def find_crossword
    @crossword = Crossword.find(params[:id])
    rescue ActiveRecord::RecordNotFound
    redirect_to :back, flash: {error: 'Sorry, that crossword could not be found.'}
  end

end
