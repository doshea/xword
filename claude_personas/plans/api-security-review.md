# P2-4: API Cleanup — Keep Only NYT GitHub Proxy

## Summary

Delete all API endpoints except `GET /api/nyt/:year/:month/:day` (GitHub puzzle proxy).

The `/api/users` and `/api/crosswords` namespaces are unauthenticated, unused by frontend,
and leak user PII + puzzle solutions. The `/api/nyt_source` route is also unused by frontend
(the `from_xwordinfo` method it wraps is called internally by `NytGithubRecorder`, not via HTTP).

The `/api/users/friends` endpoint **is** consumed by `invite_controller.js` (team invite modal),
so it must be relocated before the `Api::UsersController` is deleted.

---

## Builder Task

### Files to Change

| File | Action |
|------|--------|
| `app/controllers/api/users_controller.rb` | **Delete file** |
| `app/controllers/api/crosswords_controller.rb` | **Delete file** |
| `app/controllers/api_controller.rb` | Delete `nyt_source` action; add `friends` action (moved from Api::UsersController) |
| `config/routes.rb` | Remove `nyt_source` route, `namespace :users`, `namespace :crosswords`; add `get '/friends' => :friends` |
| `app/views/crosswords/partials/_team.html.haml` | Change `api_users_friends_path` → `api_friends_path` |
| `app/models/crossword.rb` | Delete `format_for_api` method (lines 383-392) |
| `app/models/comment.rb` | Delete `format_for_api` method (lines 74-81) |
| `spec/requests/api_spec.rb` | Delete crossword + user + nyt_source describe blocks; add `friends` spec; keep nyt (GitHub) specs |

### Detailed Changes

**1. `api_controller.rb` — final state:**

```ruby
class ApiController < ApplicationController

  # GET /api/nyt/:year/:month/:day
  def nyt
    date_from_params
    @data = NytPuzzleFetcher.from_github(@date)

    respond_to do |format|
      format.xml  { render xml: JSON.parse(@data) }
      format.json { render json: @data.to_s }
    end
  rescue JSON::ParserError
    head :bad_gateway
  end

  # GET /api/friends (JSON) — used by invite_controller.js
  def friends
    return head :unauthorized unless @current_user

    render json: @current_user.friends
                   .select(:id, :first_name, :last_name, :username, :image)
                   .map { |u| {
                     id: u.id,
                     username: u.username,
                     display_name: u.display_name,
                     avatar_url: u.image.present? ? u.image.search.url : ActionController::Base.helpers.asset_path('default_images/user.jpg')
                   }}
  end

  private

  def date_from_params
    @date = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
  end
end
```

**2. `config/routes.rb` — api namespace becomes:**

```ruby
namespace :api, defaults: { format: :json } do
  get '/nyt/:year/:month/:day' => :nyt
  get '/friends' => :friends
end
```

**3. `_team.html.haml` — update route helper:**

```
- 'invite-friends-url-value': api_users_friends_path
+ 'invite-friends-url-value': api_friends_path
```

**4. `crossword.rb` — delete lines 383-392** (`format_for_api`)

**5. `comment.rb` — delete lines 74-81** (`format_for_api`)

**6. `spec/requests/api_spec.rb` — final state:**

```ruby
RSpec.describe 'API', type: :request do
  # NYT GitHub proxy
  describe 'GET /api/nyt/:year/:month/:day' do
    let(:fake_json) { '{"title":"Test Puzzle","size":{"rows":15,"cols":15}}' }

    before { allow(NytPuzzleFetcher).to receive(:from_github).and_return(fake_json) }

    it 'returns JSON data' do
      get '/api/nyt/2024/1/15'
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include('application/json')
    end
  end

  describe 'GET /api/nyt/:year/:month/:day (invalid JSON from upstream)' do
    before { allow(NytPuzzleFetcher).to receive(:from_github).and_return('not valid json {{') }

    it 'returns 502 when upstream returns invalid JSON' do
      get '/api/nyt/2024/1/15.xml'
      expect(response).to have_http_status(:bad_gateway)
    end
  end

  # Friends API (team invite modal)
  describe 'GET /api/friends' do
    it 'returns 401 when not logged in' do
      get '/api/friends'
      expect(response).to have_http_status(:unauthorized)
    end

    context 'when logged in' do
      let(:user) { create(:user, :with_test_password) }
      before { log_in_as(user) }

      it 'returns JSON array' do
        get '/api/friends'
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to be_an(Array)
      end
    end
  end
end
```

### Batch Order

1. Move `friends` action to `ApiController`
2. Update routes.rb (remove 3 routes + 2 namespaces, add 1 friends route)
3. Update `_team.html.haml` route helper
4. Delete `api/users_controller.rb` and `api/crosswords_controller.rb`
5. Delete `format_for_api` from `crossword.rb` and `comment.rb`
6. Rewrite `spec/requests/api_spec.rb` (keep NYT, add friends, delete rest)
7. Run `bundle exec rspec`

### Acceptance Criteria

- [ ] `GET /api/users` → 404 (route gone)
- [ ] `GET /api/users/search` → 404 (route gone)
- [ ] `GET /api/crosswords/search` → 404 (route gone)
- [ ] `GET /api/crosswords/simple` → 404 (route gone)
- [ ] `GET /api/nyt_source/2024/1/15` → 404 (route gone)
- [ ] `GET /api/nyt/2024/1/15` → still works
- [ ] `GET /api/friends` → 401 unauthenticated, 200 with JSON when logged in
- [ ] Team invite modal still loads friends list
- [ ] `format_for_api` grep returns zero hits
- [ ] All specs pass

### Estimated Effort

~25 minutes. Straightforward deletion + one action relocation.
