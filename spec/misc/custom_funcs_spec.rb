describe 'custom_funcs' do
  include TimeHelper

  describe 'time_difference_hash' do
    it 'returns a vaguely correct hash of time difference' do
      #TODO make milliseconds work
      days = (rand*365*300).floor
      hours = (rand*24).floor
      minutes = (rand*60).floor
      seconds = (rand*60).floor

      # !(milliseconds = (rand*1000).floor
      older_time = Time.new(1800, 1, 1)
      newer_time = older_time + days.days + hours.hours + minutes.minutes + seconds.seconds
      result = time_difference_hash(newer_time, older_time)
      expect(result.keys).to eq([:days, :hours, :minutes, :seconds, :milliseconds])
      expect(result[:days]).to eq days
    end
  end

end
