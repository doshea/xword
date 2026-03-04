// ActionCable subscription for real-time notifications.
// Loaded on every page for logged-in users (via application.html.haml).
// Depends on: actioncable.js (loaded before this file).

(function() {
  // Guard: only run if the user is logged in (nav-mail badge exists)
  var navMail = document.getElementById('nav-mail');
  if (!navMail) return;

  var consumer = ActionCable.createConsumer();
  consumer.subscriptions.create('NotificationsChannel', {
    received: function(data) {
      if (data.event === 'new_notification') {
        updateBadge(data.unread_count);
        prependToInbox(data.html);
        refreshDropdown();
      }
    }
  });

  function updateBadge(count) {
    var badge = navMail.querySelector('.xw-badge');
    if (count > 0) {
      navMail.classList.add('unread');
      var container = document.getElementById('notification-badge');
      if (!badge) {
        badge = document.createElement('span');
        badge.className = 'xw-badge';
        if (container) {
          container.appendChild(badge);
        }
      }
      badge.textContent = count > 99 ? '99+' : count;
    } else {
      navMail.classList.remove('unread');
      if (badge) badge.remove();
    }
  }

  function prependToInbox(html) {
    var list = document.getElementById('notifications-list');
    if (!list) return;  // not on full inbox page
    var empty = document.getElementById('notifications-empty');
    if (empty) empty.remove();
    list.insertAdjacentHTML('afterbegin', html);
  }

  // Refresh the nav dropdown content if it's been loaded
  function refreshDropdown() {
    if (typeof window.StimulusApp !== 'undefined' &&
        typeof window.StimulusApp.getControllerForElementAndIdentifier === 'function') {
      var controller = window.StimulusApp
        .getControllerForElementAndIdentifier(navMail, 'notification-dropdown');
      if (controller) {
        controller.refresh();
      }
    }
  }
})();
