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

end