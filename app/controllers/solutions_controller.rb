class SolutionsController < ApplicationController
  def index
  end
  def update
    solution = Solution.find(params[:id])
    solution.letters = params[:letters]
    solution.save
  end
end