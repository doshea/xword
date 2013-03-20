class CluesController < ApplicationController
  def index
    @clues = Clue.all
  end
  def show
    @clue = Clue.find(params[:id])
  end
end