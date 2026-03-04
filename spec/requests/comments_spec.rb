RSpec.describe 'Comments', type: :request do
  let_it_be(:user)      { create(:user, :with_test_password) }
  let_it_be(:crossword) { create(:crossword) }

  before do
    # Stub ActionCable broadcasts
    allow(ActionCable.server).to receive(:broadcast)
    allow(ApplicationController).to receive(:render).and_call_original
  end

  # -------------------------------------------------------------------------
  # POST /comments/:id/reply — parent-child threading
  # -------------------------------------------------------------------------
  describe 'POST /comments/:id/reply (reply threading)' do
    let(:base_comment) { Comment.create!(content: 'Great puzzle!', user: user, crossword: crossword) }

    before do
      log_in_as(user)
    end

    it 'creates a reply linked to the parent comment via base_comment_id' do
      post "/comments/#{base_comment.id}/reply",
           params: { content: 'Thanks!' },
           headers: { 'Accept' => Mime[:turbo_stream].to_s }

      reply = Comment.last
      expect(reply.base_comment_id).to eq base_comment.id
      expect(reply.content).to eq 'Thanks!'
    end

    it 'makes the reply accessible through the parent comment replies association' do
      post "/comments/#{base_comment.id}/reply",
           params: { content: 'I agree!' },
           headers: { 'Accept' => Mime[:turbo_stream].to_s }

      expect(base_comment.reload.replies.count).to eq 1
      expect(base_comment.replies.first.content).to eq 'I agree!'
    end

    it 'assigns the reply to the current user' do
      post "/comments/#{base_comment.id}/reply",
           params: { content: 'Nice one!' },
           headers: { 'Accept' => Mime[:turbo_stream].to_s }

      reply = Comment.last
      expect(reply.user).to eq user
    end

    it 'does not set crossword_id on the reply (inherited through base_comment)' do
      post "/comments/#{base_comment.id}/reply",
           params: { content: 'Reply text' },
           headers: { 'Accept' => Mime[:turbo_stream].to_s }

      reply = Comment.last
      # Replies get crossword through base_comment, not directly
      expect(reply.crossword_id).to be_nil
    end

    it 'cascades destruction: destroying parent also destroys its replies' do
      post "/comments/#{base_comment.id}/reply",
           params: { content: 'Will be destroyed' },
           headers: { 'Accept' => Mime[:turbo_stream].to_s }

      expect { base_comment.destroy }.to change(Comment, :count).by(-2)
    end

    it 'rejects replies to replies (prevents deep nesting)' do
      reply = Comment.create!(content: 'A reply', user: user, base_comment: base_comment)

      post "/comments/#{reply.id}/reply",
           params: { content: 'Nested too deep' },
           headers: { 'Accept' => Mime[:turbo_stream].to_s }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  # -------------------------------------------------------------------------
  # Comment Notifications
  # -------------------------------------------------------------------------
  describe 'comment notifications' do
    let(:puzzle_owner) { create(:user) }
    let(:owned_crossword) { create(:crossword, :smaller, user: puzzle_owner) }

    before { log_in_as(user) }

    it 'notifies puzzle owner when someone else comments' do
      expect {
        post "/comments/#{owned_crossword.id}/add_comment",
             params: { content: 'Nice puzzle!' },
             headers: { 'Accept' => Mime[:turbo_stream].to_s }
      }.to change(Notification, :count).by(1)

      notification = Notification.last
      expect(notification.user).to eq(puzzle_owner)
      expect(notification.actor).to eq(user)
      expect(notification.notification_type).to eq('comment_on_puzzle')
    end

    it 'does not notify when commenting on your own puzzle' do
      my_crossword = create(:crossword, :smaller, user: user)

      expect {
        post "/comments/#{my_crossword.id}/add_comment",
             params: { content: 'My own comment' },
             headers: { 'Accept' => Mime[:turbo_stream].to_s }
      }.not_to change(Notification, :count)
    end

    it 'notifies comment author when someone else replies' do
      other_user = create(:user)
      base_comment = Comment.create!(content: 'Original', user: other_user, crossword: crossword)

      expect {
        post "/comments/#{base_comment.id}/reply",
             params: { content: 'Great point!' },
             headers: { 'Accept' => Mime[:turbo_stream].to_s }
      }.to change(Notification, :count).by(1)

      notification = Notification.last
      expect(notification.user).to eq(other_user)
      expect(notification.notification_type).to eq('comment_reply')
    end

    it 'does not notify when replying to your own comment' do
      my_comment = Comment.create!(content: 'My comment', user: user, crossword: crossword)

      expect {
        post "/comments/#{my_comment.id}/reply",
             params: { content: 'Adding more context' },
             headers: { 'Accept' => Mime[:turbo_stream].to_s }
      }.not_to change(Notification, :count)
    end
  end
end
