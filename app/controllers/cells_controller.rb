class CellsController < ApplicationController
  def index
    @cells = Cell.all
  end
end