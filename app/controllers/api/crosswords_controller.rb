class Api::CrosswordsController < ApplicationController

  def search
    crossword = Crossword.find_by(title: params[:title])
    return head :not_found unless crossword
    render json: crossword.format_for_api(params[:include_comments])
  end

  def simple
    crossword = Crossword.find_by(title: params[:title])
    return head :not_found unless crossword
    if params[:spoil] && params[:spoil].downcase.in?(%w[t true])
      render plain: crossword.to_s(nil, params[:spoil])
    else
      render plain: crossword.to_s(nil, false)
    end
  end

end
