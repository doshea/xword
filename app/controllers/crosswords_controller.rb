class CrosswordsController < ApplicationController
  before_action :ensure_logged_in, only: [:create]
  before_action :ensure_owner_or_admin, only: [:edit, :update, :destroy, :publish, :add_potential_word]

  def show
    @crossword = Crossword.find(params[:id])
    if @crossword
      if @current_user
        @solution = Solution.find_or_create_by(
          crossword_id: @crossword.id,
          user_id: @current_user.id,
          team: false
        )
        @solution.fill_letters
      end
      @cells = @crossword.cells.asc_indices
    else
      #redirect to 404 page
    end
  end

  def new
    @crossword = Crossword.new
  end

  def create
    @crossword = Crossword.new(params[:crossword])
    @crossword.user = @current_user
    if @crossword.save
      @crossword.link_cells_to_neighbors
      redirect_to edit_crossword_path(@crossword)
    else
      render :new
    end
  end

  def edit
    if @crossword.published?
      redirect_to @crossword
    else
      @cells = @crossword.cells.asc_indices
      @across_cells = @crossword.across_start_cells.includes(:across_clue).asc_indices
      @down_cells = @crossword.down_start_cells.includes(:across_clue).asc_indices
      @across_clues = Clue.joins(:across_cells).where(cells: {crossword_id: @crossword.id}).order('cells.index')
      @down_clues = Clue.joins(:down_cells).where(cells: {crossword_id: @crossword.id}).order('cells.index')
      @potential_words = @crossword.potential_words.desc_length
    end
  end

  def update
    crossword = Crossword.find(params[:id])
    crossword.update_attributes(params[:crossword])
    render nothing: true
  end

  def publish
    @crossword.publish! unless @crossword.published?
    redirect @crossword
  end

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

  def team
    @crossword = Crossword.find(params[:id])
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

  def add_potential_word
    @crossword = Crossword.find(params[:id])
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

  def remove_potential_word
    @crossword = Crossword.find(params[:id])
    if @crossword
      @word = Word.find(params[:potential_word_id])
      @crossword.potential_words.delete(@word)
    else
      render nothing: true
    end
  end

  def favorite
    @crossword = Crossword.find(params[:id])
    if @crossword && @current_user
      unless @current_user.favorites.include? @crossword
        if FavoritePuzzle.create(user_id: @current_user.id, crossword_id: @crossword.id)
          render :favorite_unfavorite
        else

        end
      end
    end
  end

  def unfavorite
    @crossword = Crossword.find(params[:id])
    if @crossword && @current_user
      existing_favorite = FavoritePuzzle.find_by_user_id_and_crossword_id(@current_user.id, @crossword.id)
      existing_favorite.destroy if existing_favorite
      render :favorite_unfavorite
    end
  end

  def solution_choice
    @crossword = Crossword.find(params[:id])

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

  def batch
    @crosswords = Crossword.find(params[:ids])
    @crosswords_remaining = @crosswords[Crossword.per_page..-1]
    @crosswords = @crosswords[0...Crossword.per_page]
  end

  private
  def ensure_owner_or_admin
    @crossword = Crossword.find(params[:id])
    redirect_to(unauthorized_path) if !(@current_user.is_admin or @current_user == @crossword.user)
  end
end
