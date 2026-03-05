// Notification click: marks as read (fire-and-forget PATCH) and navigates to
// destination on dead-space clicks. Nested links/buttons handle their own navigation.
//
// Data attributes (on .xw-notification):
//   data-notification-url       — primary destination (profile, puzzle, team)
//   data-notification-mark-url  — PATCH path to mark_read

class NotificationClickController extends Stimulus.Controller {
  click(event) {
    this.markRead();

    // If clicking an interactive element, let it handle navigation
    if (event.target.closest('a, button, form, input')) return;

    // Navigate to primary destination
    var url = this.element.dataset.notificationUrl;
    if (url) {
      event.preventDefault();
      window.Turbo ? Turbo.visit(url) : (window.location.href = url);
    }
  }

  markRead() {
    if (this.element.dataset.notificationRead) return;

    var markUrl = this.element.dataset.notificationMarkUrl;
    if (!markUrl) return;

    var csrfMeta = document.querySelector('meta[name="csrf-token"]');
    var token = csrfMeta ? csrfMeta.content : '';

    fetch(markUrl, {
      method: 'PATCH',
      keepalive: true,
      headers: {
        'Accept': 'application/json',
        'X-CSRF-Token': token
      }
    });

    // Optimistic UI update
    this.element.classList.remove('xw-notification--unread');
    this.element.dataset.notificationRead = 'true';

    // Decrement nav badge count
    this.updateBadge();
  }

  updateBadge() {
    var badge = document.querySelector('#notification-badge .xw-badge');
    if (!badge) return;

    var count = parseInt(badge.textContent, 10);
    if (isNaN(count)) return;

    count--;
    if (count <= 0) {
      badge.remove();
      var navMail = document.getElementById('nav-mail');
      if (navMail) navMail.classList.remove('unread');
    } else {
      badge.textContent = count > 99 ? '99+' : count;
    }
  }
}

window.StimulusApp.register('notification-click', NotificationClickController);
