// Month-by-month calendar for NYT puzzles. Reads puzzle dates from a JSON
// data attribute, renders a 7-column grid (Mon-Sun), highlights days with puzzles.
(function() {
  var MONTH_NAMES = ['January','February','March','April','May','June',
                     'July','August','September','October','November','December'];
  var DAY_HEADERS = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];

  function pad(n) { return n < 10 ? '0' + n : '' + n; }

  var CalendarController = class extends Stimulus.Controller {
    static get values() { return { puzzles: String, min: String, max: String }; }

    connect() {
      this.puzzles = JSON.parse(this.puzzlesValue || '{}');
      this.minDate = this.minValue ? new Date(this.minValue + 'T00:00:00') : null;
      this.maxDate = this.maxValue ? new Date(this.maxValue + 'T00:00:00') : null;

      if (this.maxDate) {
        this.currentYear = this.maxDate.getFullYear();
        this.currentMonth = this.maxDate.getMonth();
      } else {
        var now = new Date();
        this.currentYear = now.getFullYear();
        this.currentMonth = now.getMonth();
      }

      this.render();
    }

    prev() {
      this.currentMonth--;
      if (this.currentMonth < 0) {
        this.currentMonth = 11;
        this.currentYear--;
      }
      if (!this.canNavigate(this.currentYear, this.currentMonth, 'prev')) {
        // Undo the change
        this.currentMonth++;
        if (this.currentMonth > 11) {
          this.currentMonth = 0;
          this.currentYear++;
        }
        return;
      }
      this.render();
    }

    next() {
      this.currentMonth++;
      if (this.currentMonth > 11) {
        this.currentMonth = 0;
        this.currentYear++;
      }
      if (!this.canNavigate(this.currentYear, this.currentMonth, 'next')) {
        // Undo the change
        this.currentMonth--;
        if (this.currentMonth < 0) {
          this.currentMonth = 11;
          this.currentYear--;
        }
        return;
      }
      this.render();
    }

    canNavigate(year, month, direction) {
      if (direction === 'prev' && this.minDate) {
        // Last day of the target month must be >= minDate
        var lastDay = new Date(year, month + 1, 0);
        return lastDay >= this.minDate;
      }
      if (direction === 'next' && this.maxDate) {
        // First day of the target month must be <= maxDate
        var firstDay = new Date(year, month, 1);
        return firstDay <= this.maxDate;
      }
      return true;
    }

    render() {
      var year = this.currentYear;
      var month = this.currentMonth;
      var firstDay = new Date(year, month, 1);
      var daysInMonth = new Date(year, month + 1, 0).getDate();
      // JS getDay(): 0=Sun..6=Sat. Convert to Mon-based: Mon=0..Sun=6
      var startOffset = (firstDay.getDay() + 6) % 7;

      // Can we navigate prev/next?
      var canPrev = true;
      var canNext = true;
      if (this.minDate) {
        var prevMonth = month - 1 < 0 ? 11 : month - 1;
        var prevYear = month - 1 < 0 ? year - 1 : year;
        canPrev = this.canNavigate(prevYear, prevMonth, 'prev');
      }
      if (this.maxDate) {
        var nextMonth = month + 1 > 11 ? 0 : month + 1;
        var nextYear = month + 1 > 11 ? year + 1 : year;
        canNext = this.canNavigate(nextYear, nextMonth, 'next');
      }

      var html = '';

      // Navigation
      html += '<div class="xw-calendar__nav">';
      html += '<button class="xw-btn xw-btn--ghost" data-action="click->calendar#prev"' +
              (canPrev ? '' : ' disabled') + '>\u2039</button>';
      html += '<h3 class="xw-calendar__title">' + MONTH_NAMES[month] + ' ' + year + '</h3>';
      html += '<button class="xw-btn xw-btn--ghost" data-action="click->calendar#next"' +
              (canNext ? '' : ' disabled') + '>\u203a</button>';
      html += '</div>';

      // Grid
      html += '<div class="xw-calendar__grid">';

      // Day headers
      for (var d = 0; d < 7; d++) {
        html += '<div class="xw-calendar__header">' + DAY_HEADERS[d] + '</div>';
      }

      // Empty cells before first day
      for (var e = 0; e < startOffset; e++) {
        html += '<div class="xw-calendar__cell"></div>';
      }

      // Day cells
      for (var day = 1; day <= daysInMonth; day++) {
        var dateStr = year + '-' + pad(month + 1) + '-' + pad(day);
        var puzzlePath = this.puzzles[dateStr];

        if (puzzlePath) {
          html += '<a href="' + puzzlePath + '" class="xw-calendar__cell xw-calendar__cell--has-puzzle" title="' + dateStr + '">' + day + '</a>';
        } else {
          html += '<div class="xw-calendar__cell">' + day + '</div>';
        }
      }

      html += '</div>';
      this.element.innerHTML = html;
    }
  };

  window.StimulusApp.register('calendar', CalendarController);
})();
