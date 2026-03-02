require 'spec_helper'

describe 'comments/partials/_comment' do
  let(:user)      { create(:user) }
  let(:crossword) { create(:crossword, :smaller, user: user) }
  let(:comment)   { create(:comment, user: user, crossword: crossword) }

  # Anonymous context: the logged-in branch (`- if @current_user`) is entirely
  # skipped, so `link_to nil` (cancel-button) is never reached.  The article
  # wrapper and its id are the key accessibility assertions.
  context 'anonymous viewer' do
    before do
      assign(:current_user, nil)
      render partial: 'comments/partials/comment', locals: { comment: comment }
    end

    it 'renders the comment as an <article> element, not a <div>' do
      expect(rendered).to have_selector("article##{dom_id(comment)}", visible: :all)
    end

    it 'does not render a bare <div> with the comment id' do
      expect(rendered).not_to have_selector("div##{dom_id(comment)}", visible: :all)
    end

    it 'contains the comment content inside the article' do
      expect(rendered).to have_selector("article##{dom_id(comment)}", text: comment.content, visible: :all)
    end

    it 'renders the reply count as a <p>, not an <h6>' do
      expect(rendered).to have_selector("p.xw-comment__reply-count", visible: :all)
      expect(rendered).not_to have_selector("h6.reply-count", visible: :all)
    end
  end
end
