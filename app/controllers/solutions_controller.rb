class SolutionsController < ApplicationController
  def index
  end
  def update
    solution = Solution.find(params[:id])
    solution.letters = params[:letters]
    solution.save
  end
  def get_incorrect
    @mismatches = Solution.find(params[:id]).crossword.return_mismatches(params[:letters])
  end
  def check_correctness
    @correctness = Solution.find(params[:id]).crossword.letters == params[:letters]
  end
end