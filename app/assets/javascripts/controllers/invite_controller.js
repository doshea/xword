// Stimulus controller for inviting friends to team solve.
// Fetches friends list from API, renders dropdown, submits invite.
(function() {
  var InviteController = class extends Stimulus.Controller {
    static get targets() { return ['body']; }
    static get values() { return { solutionId: Number, friendsUrl: String }; }

    loadFriends() {
      var self = this;
      fetch(this.friendsUrlValue, {
        headers: { 'Accept': 'application/json' }
      })
      .then(function(r) { return r.json(); })
      .then(function(friends) {
        if (friends.length === 0) {
          self.bodyTarget.innerHTML = '<p class="xw-text-muted">No friends yet. Share the link above!</p>';
          return;
        }
        var html = '<div class="team-modal__friends-list">';
        friends.forEach(function(f) {
          html += '<button type="button" class="team-modal__friend-btn" ' +
                  'data-action="invite#sendInvite" data-user-id="' + f.id + '">' +
                  '<span class="team-modal__friend-name">' + self.escapeHtml(f.display_name) + '</span>' +
                  '<span class="team-modal__friend-username">@' + self.escapeHtml(f.username) + '</span>' +
                  '</button>';
        });
        html += '</div>';
        self.bodyTarget.innerHTML = html;
      })
      .catch(function() {
        self.bodyTarget.innerHTML = '<p class="xw-text-danger">Could not load friends.</p>';
      });
    }

    sendInvite(event) {
      var btn = event.currentTarget;
      var userId = btn.dataset.userId;
      var csrfToken = document.querySelector('meta[name="csrf-token"]').content;
      var self = this;

      btn.disabled = true;
      btn.textContent = 'Sending…';

      fetch('/puzzle_invites', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken,
          'Accept': 'application/json'
        },
        body: JSON.stringify({
          solution_id: self.solutionIdValue,
          user_id: userId
        })
      })
      .then(function(r) {
        if (r.ok) {
          btn.textContent = 'Invited ✓';
          btn.classList.add('team-modal__friend-btn--invited');
        } else {
          btn.textContent = 'Failed';
          btn.disabled = false;
        }
      })
      .catch(function() {
        btn.textContent = 'Failed';
        btn.disabled = false;
      });
    }

    escapeHtml(str) {
      var div = document.createElement('div');
      div.textContent = str;
      return div.innerHTML;
    }
  };

  window.StimulusApp.register('invite', InviteController);
})();
