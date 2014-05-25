class ApiController < ApplicationController

  #GET /api/history or api_history_path
  #TODO: fix this now that puzzle history is handled differently
  def history
    respond_to do |format|
      # @data = eval(HTTParty.get('https://raw.github.com/doshea/nyt_puzzle_history/master/nyt_puzzle_history.rb'))
      @data = {:'1' => 3}
      format.html do

      end

      format.json do
        render json: @data
      end

      format.xml do
        render xml: @data
      end
    end
  end

  def nyt
    # url_prefix = 'https://raw.githubusercontent.com/doshea/nyt_puzzle_history/master'
    url_prefix = "http://www.xwordinfo.com/JSON/Data.aspx"
    year = params[:year]
    month = sprintf('%02d', params[:month])
    day = sprintf('%02d', params[:day])
    # url = "#{url_prefix}/#{year}/#{month}/#{day}.json"
    url = "#{url_prefix}?date=#{month}/#{day}/#{year}"
    @data = HTTParty.get(url, format: 'json') #proper way to grab json and keep it json

    respond_to do |format|
      format.html do
        render text: @data
      end
      format.json do
        render json: @data.to_s
      end
    end
  end

end