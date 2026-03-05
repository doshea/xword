class UnpublishedCrosswordsController < ApplicationController
  before_action :find_object, :ensure_owner_or_admin, except: [:new, :create]
  before_action :ensure_logged_in, only: [:new, :create]

  def new
    @ucw = UnpublishedCrossword.new
  end

  def create
    @ucw = UnpublishedCrossword.new(create_params)
    @ucw.user = @current_user
    if @ucw.save
      redirect_to edit_unpublished_crossword_path(@ucw)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @clue_numbers = found_object.letters_to_clue_numbers
  end

  def update
    found_object.update(update_params)
    render json: { ok: true }
  end

  def update_letters
    letters = params[:letters].map do |l|
      s = l.to_s
      if s == "0"
        nil   # void cell
      elsif s.strip.empty?
        ''    # non-void empty cell
      else
        s     # letter
      end
    end
    @save_counter = params[:save_counter]
    puzzle_hash = {letters: letters, circles: params[:circles], across_clues: params[:across_clues], down_clues: params[:down_clues]}
    found_object.update(puzzle_hash)
    respond_to do |f|
      f.json { render json: { save_counter: @save_counter } }
      f.js   # Legacy: update_letters.js.erb
    end
  end

  def publish
    crossword = CrosswordPublisher.publish(found_object)
    redirect_to crossword_path(crossword), flash: { success: 'Your puzzle has been published!' }
  rescue CrosswordPublisher::BlankCellsError => e
    redirect_to edit_unpublished_crossword_path(found_object),
      flash: { error: "Cannot publish: #{e.message}." }
  rescue StandardError => e
    redirect_to edit_unpublished_crossword_path(found_object),
      flash: { error: "Publishing failed: #{e.message}" }
  end

  def add_potential_word
    @word = params[:word].upcase
    @added = @unpublished_crossword.add_potential_word(@word)
  end

  def remove_potential_word
    @word = params[:word].upcase
    @unpublished_crossword.remove_potential_word(@word)
  end

  private
  def create_params
    params.require(:unpublished_crossword).permit(:title, :rows, :cols, :description)
  end
  def update_params
    params.require(:unpublished_crossword).permit(:title, :rows, :cols, :description, :mirror_voids, :circle_mode, :one_click_void, :multiletter_mode)
  end

end