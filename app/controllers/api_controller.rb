class ApiController < ApplicationController

  #GET /api/nyt/:year/:month/:date
  def nyt
    date_from_params
    @data = Crossword.get_github_nyt_from_date(@date)

    respond_to do |format|
      format.xml do
        render xml: JSON.parse(@data)
      end
      format.json do
        render json: @data.to_s
      end
    end
  
  end

  #GET /api/nyt_source/:year/:month/:date or api_path
  def nyt_source
    date_from_params
    @data = Crossword.get_nyt_from_date(@date)

    respond_to do |format|
      format.xml do
        render xml: JSON.parse(@data)
      end
      format.json do
        render json: @data.to_s
      end
    end
  
  end

  
  private
  def date_from_params
    @date = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
  end

end