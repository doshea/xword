describe CommentsController do
  let(:user)      { create(:user) }
  let(:crossword) { create(:crossword) }

  # All three actions render .turbo_stream.erb templates with no HTML fallback.
  # Setting the Accept header tells Rails to expect turbo_stream format;
  # render_views is false (rspec-rails default) so no template is actually loaded.
  before { request.accept = Mime[:turbo_stream].to_s }

  # Simulate logged-in state via session-based auth (ApplicationController#authenticate)
  def log_in(u)
    session[:user_id] = u.id
  end

  describe 'POST #add_comment' do
    let(:content) { 'This puzzle was absolutely delightful!' }

    context 'when anonymous' do
      it 'returns 401 unauthorized' do
        post :add_comment, params: { id: crossword.id, content: content }
        expect(response).to have_http_status(:unauthorized)
      end

      it 'does not create a comment' do
        expect {
          post :add_comment, params: { id: crossword.id, content: content }
        }.not_to change(Comment, :count)
      end
    end

    context 'when logged in, under the comment limit' do
      before { log_in(user) }

      it 'creates a comment' do
        expect {
          post :add_comment, params: { id: crossword.id, content: content }
        }.to change(Comment, :count).by(1)
      end

      it 'attaches the comment to the crossword' do
        post :add_comment, params: { id: crossword.id, content: content }
        expect(crossword.comments.last.content).to eq content
      end

      it 'attaches the comment to the current user' do
        post :add_comment, params: { id: crossword.id, content: content }
        expect(user.comments.last.content).to eq content
      end
    end

    context 'when logged in, at the comment limit' do
      before do
        log_in(user)
        # Fill up this user's comment quota on this crossword
        Comment::MAX_PER_CROSSWORD.times do
          Comment.create!(content: 'filler', user: user, crossword: crossword)
        end
      end

      it 'returns 403 forbidden' do
        post :add_comment, params: { id: crossword.id, content: content }
        expect(response).to have_http_status(:forbidden)
      end

      it 'does not create an additional comment' do
        expect {
          post :add_comment, params: { id: crossword.id, content: content }
        }.not_to change(Comment, :count)
      end
    end
  end

  describe 'POST #reply' do
    let(:base_comment) { create(:comment, user: user, crossword: crossword) }

    context 'when anonymous' do
      it 'does not create a reply' do
        base_comment  # ensure record exists before counting
        expect {
          post :reply, params: { id: base_comment.id, content: 'my reply' }
        }.not_to change(Comment, :count)
      end
    end

    context 'when logged in' do
      before { log_in(user) }

      it 'creates a reply' do
        base_comment
        expect {
          post :reply, params: { id: base_comment.id, content: 'my reply' }
        }.to change(Comment, :count).by(1)
      end

      it 'attaches the reply to the base comment' do
        post :reply, params: { id: base_comment.id, content: 'my reply' }
        expect(base_comment.reload.replies.count).to eq 1
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:comment) { create(:comment, user: user, crossword: crossword) }

    context 'as the comment owner' do
      before { log_in(user); comment }

      it 'destroys the comment' do
        expect {
          delete :destroy, params: { id: comment.id }
        }.to change(Comment, :count).by(-1)
      end
    end

    context 'as an admin' do
      let(:admin) { create(:admin) }
      before { log_in(admin); comment }

      it 'destroys the comment' do
        expect {
          delete :destroy, params: { id: comment.id }
        }.to change(Comment, :count).by(-1)
      end
    end

    context 'as a different user' do
      let(:other_user) { create(:user) }
      before { log_in(other_user); comment }

      it 'does not destroy the comment' do
        expect {
          delete :destroy, params: { id: comment.id }
        }.not_to change(Comment, :count)
      end
    end

    context 'when anonymous' do
      before { comment }

      it 'does not destroy the comment' do
        expect {
          delete :destroy, params: { id: comment.id }
        }.not_to change(Comment, :count)
      end
    end
  end
end
