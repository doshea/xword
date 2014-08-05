class Api::CrosswordsController < ApplicationController

  def search
    crossword = Crossword.find_by(title: params[:title])
    render json: crossword.format_for_api(params[:include_comments])
  end

  def simple
    crossword = Crossword.find_by(title: params[:title])
    if params[:spoil] && params[:spoil].downcase.in?('t', 'true')
      render text: crossword.to_s(nil, params[:spoil])
    else
      render text: crossword.to_s(nil, false)
    end
  end

end