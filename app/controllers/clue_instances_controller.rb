class ClueInstancesController < ApplicationController
  def index
    @clue_instances = ClueInstance.all
  end
end