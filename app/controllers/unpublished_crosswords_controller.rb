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
    found_object.update_attributes(update_params)
    render nothing: true
  end

  def update_letters
    letters = params[:letters].map{|l| l unless l == 0}
    @save_counter = params[:save_counter]
    found_object.update_attribute(:letters, letters)
    found_object.update_attribute(:across_clues, params[:across_clues])
    found_object.update_attribute(:down_clues, params[:down_clues])
  end

  def publish

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
    params.require(:unpublished_crossword).permit(:title, :rows, :cols, :description)
  end

end