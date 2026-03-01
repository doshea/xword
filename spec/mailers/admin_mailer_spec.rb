describe AdminMailer do
  describe '#nyt_upload_error_email' do
    let(:mail) { AdminMailer.nyt_upload_error_email }

    it 'sends to the admin address' do
      expect(mail.to).to eq ['info@crossword-cafe.com']
    end

    it 'includes today\'s date in the subject' do
      expect(mail.subject).to include(Date.today.strftime('%A, %b %d %Y'))
    end

    it 'has NYT Upload ERROR in the subject' do
      expect(mail.subject).to start_with('NYT Upload ERROR:')
    end

    it 'sends from info@crossword-cafe.com' do
      expect(mail.from).to eq ['info@crossword-cafe.com']
    end

    it 'includes the error message in the body' do
      expect(mail.body.encoded).to include("didn't work")
    end
  end
end
