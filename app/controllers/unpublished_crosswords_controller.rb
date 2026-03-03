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
      redirect_to new_unpublished_crossword_path, flash: {error: 'There was a problem creating your crossword.'}
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
    letters = params[:letters].map{|l| l unless l == "0" || l.blank?}
    @save_counter = params[:save_counter]
    puzzle_hash = {letters: letters, circles: params[:circles], across_clues: params[:across_clues], down_clues: params[:down_clues]}
    found_object.update(puzzle_hash)
    respond_to do |f|
      f.json { render json: { save_counter: @save_counter } }
      f.js   # Legacy: update_letters.js.erb
    end
  end

  def publish
    ucw = found_object

    # Validate all non-void cells have letters
    blank_count = ucw.letters.count { |l| !l.nil? && l.blank? }
    if blank_count > 0
      redirect_to edit_unpublished_crossword_path(ucw),
        flash: { error: "Cannot publish: #{blank_count} #{'cell'.pluralize(blank_count)} still blank." }
      return
    end

    Crossword.transaction do
      # Build letters string: nil → '_' (void), letter → letter
      letters_string = ucw.letters.map { |l| l.nil? ? '_' : l }.join

      # Create crossword — callbacks auto-populate blank letters + cells
      crossword = Crossword.create!(
        title: ucw.title,
        description: ucw.description,
        rows: ucw.rows,
        cols: ucw.cols,
        user: ucw.user
      )

      # Overwrite placeholder letters/cells with actual content
      crossword.set_contents(letters_string)
      crossword.number_cells

      # Assign UCW clue content to start cells
      crossword.cells.reload.each do |cell|
        idx = cell.index - 1
        if cell.is_across_start && ucw.across_clues[idx].present?
          cell.across_clue.update!(content: ucw.across_clues[idx])
        end
        if cell.is_down_start && ucw.down_clues[idx].present?
          cell.down_clue.update!(content: ucw.down_clues[idx])
        end
      end

      # Clean up clues on void / non-start cells, then build Word records
      crossword.cells.each { |cell| cell.delete_extraneous_cells! }
      crossword.generate_words_and_link_clues

      # Transfer circles if any
      if ucw.circles.present? && ucw.circles.chars.any? { |c| c != ' ' && c != '0' }
        crossword.circles_from_array(ucw.circles.chars.map(&:to_i))
      end

      ucw.destroy!
      redirect_to crossword_path(crossword), flash: { success: 'Your puzzle has been published!' }
    end
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