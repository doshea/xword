describe 'custom_funcs' do
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

  describe Integer do
    describe '#left_digits'

    it 'can add multiple zeroes before long-digit numbers' do
      expect(1.left_digits(3)).to eq '001'
    end
    it 'adds at least one zero before short-digit numbers' do
      expect(30.left_digits(3)).to eq '030'
    end

    it 'does not effect numbers of same digit length' do
      expect(700.left_digits(3)).to eq '700'
    end
    it 'does not truncate longer numbers' do
      expect(9000.left_digits(3)).to eq '9000'
    end
  end

end