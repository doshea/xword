class Api::CrosswordsController < ApplicationController

  def search
    crossword = Crossword.find_by(title: params[:title])
    render json: crossword.format_for_api(params[:include_comments])
  end

end