class ApiController < ApplicationController

  def history
    respond_to do |format|
      @data = eval(HTTParty.get('https://raw.github.com/doshea/nyt_puzzle_history/master/nyt_puzzle_history.rb'))
      format.html do

      end

      format.json do
        render json: @data.to_json
      end

      format.xml do
        render xml: @data.to_xml
      end
    end
  end

end