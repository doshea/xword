RSpec.describe TeamsChannel, type: :channel do
  let(:user)          { create(:user) }
  let(:crossword)     { create(:crossword, :smaller) }
  let(:team_solution) { create(:solution, :team, user: user, crossword: crossword) }

  describe '#subscribed' do
    context 'with a valid team key' do
      it 'streams from the team channel' do
        subscribe(team_key: team_solution.key)
        expect(subscription).to be_confirmed
        expect(subscription).to have_stream_from("team_#{team_solution.key}")
      end
    end

    context 'with a nonexistent team key' do
      it 'rejects the subscription' do
        subscribe(team_key: 'bogus_key_123')
        expect(subscription).to be_rejected
      end
    end

    context 'with a blank team key' do
      it 'rejects the subscription' do
        subscribe(team_key: '')
        expect(subscription).to be_rejected
      end
    end

    context 'with no team key' do
      it 'rejects the subscription' do
        subscribe(team_key: nil)
        expect(subscription).to be_rejected
      end
    end
  end
end
