RSpec.describe 'Comments', type: :request do
  let(:user)      { create(:user, :with_test_password) }
  let(:crossword) { create(:crossword, :smaller) }

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
  end
end
