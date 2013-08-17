class CluesController < ApplicationController
  def index
    @clues = Clue.all
  end
  def show
    @clue = Clue.find(params[:id])
  end
  def update
    @clue = Clue.find(params[:id])
    @clue.update_attributes(params[:clue])
    render nothing: true
  end
end