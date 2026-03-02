require 'spec_helper'

describe 'comments/partials/_reply' do
  let(:user)         { create(:user) }
  let(:crossword)    { create(:crossword, :smaller, user: user) }
  let(:base_comment) { create(:comment, user: user, crossword: crossword) }
  let(:reply)        { create(:comment, user: user, crossword: crossword, base_comment: base_comment) }

  # Anonymous context: the logged-in branch (`.reply-controls`) is skipped,
  # avoiding the `link_to reply` turbo_method delete path which requires
  # route context not available in a fragment view spec.
  context 'anonymous viewer' do
    before do
      assign(:current_user, nil)
      render partial: 'comments/partials/reply', locals: { reply: reply }
    end

    it 'renders the reply as an <article> element, not a <div>' do
      expect(rendered).to have_selector("article##{dom_id(reply)}", visible: :all)
    end

    it 'does not render a bare <div> with the reply id' do
      expect(rendered).not_to have_selector("div##{dom_id(reply)}", visible: :all)
    end

    it 'contains the reply content inside the article' do
      expect(rendered).to have_selector("article##{dom_id(reply)}", text: reply.content, visible: :all)
    end

    it 'uses the xw-reply class for the article wrapper' do
      expect(rendered).to have_selector("article.xw-reply", visible: :all)
    end

    it 'renders the avatar in a xw-reply__avatar container' do
      expect(rendered).to have_selector('.xw-reply__avatar', visible: :all)
    end

    it 'renders the reply body in a xw-reply__body container' do
      expect(rendered).to have_selector('.xw-reply__body', visible: :all)
    end
  end

  context 'logged-in reply owner' do
    before do
      assign(:current_user, user)
      render partial: 'comments/partials/reply', locals: { reply: reply }
    end

    it 'does not use inline style on reply-controls' do
      expect(rendered).not_to have_selector('.reply-controls[style]', visible: :all)
    end

    it 'does not use inline style on the delete link' do
      expect(rendered).not_to have_selector('.reply-controls a[style]', visible: :all)
    end
  end
end
