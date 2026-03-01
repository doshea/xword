describe UserMailer do
  let(:user) { create(:full_user) }

  describe '#reset_password_email' do
    let(:mail) { UserMailer.reset_password_email(user) }

    it 'sends to the user' do
      expect(mail.to).to eq [user.email]
    end

    it 'sets the subject' do
      expect(mail.subject).to eq "Reset your Crossword Caf\u00e9 password"
    end

    it 'sends from dylan@crossword-cafe.org' do
      expect(mail.from).to eq ['dylan@crossword-cafe.org']
    end

    it 'includes the username in the body' do
      expect(mail.body.encoded).to include(user.username)
    end

    it 'includes a reset password link' do
      expect(mail.body.encoded).to include('reset_password')
    end
  end
end
