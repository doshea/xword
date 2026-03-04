// Month-by-month calendar for NYT puzzles. Reads puzzle dates from a JSON
// data attribute, renders a 7-column grid (Mon-Sun), highlights days with puzzles.
// Features: year navigation, smart prev/next (skips empty months), puzzle counts.
(function() {
  var MONTH_NAMES = ['January','February','March','April','May','June',
                     'July','August','September','October','November','December'];
  var DAY_HEADERS = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];

  function pad(n) { return n < 10 ? '0' + n : '' + n; }

  var CalendarController = class extends Stimulus.Controller {
    static get values() { return { puzzles: String, min: String, max: String }; }

    connect() {
      // Dataset fallback — safety net if Stimulus values API returns empty strings
      var el = this.element.dataset;
      var puzzlesRaw = this.puzzlesValue || el.calendarPuzzlesValue || '{}';
      var minRaw = this.minValue || el.calendarMinValue || '';
      var maxRaw = this.maxValue || el.calendarMaxValue || '';

      this.puzzles = JSON.parse(puzzlesRaw);
      this.minDate = minRaw ? new Date(minRaw + 'T00:00:00') : null;
      this.maxDate = maxRaw ? new Date(maxRaw + 'T00:00:00') : null;

      // Build month index: "YYYY-MM" => count, and year set
      this.monthIndex = {};
      this.yearSet = new Set();

      var dates = Object.keys(this.puzzles);
      for (var i = 0; i < dates.length; i++) {
        var parts = dates[i].split('-');
        var key = parts[0] + '-' + parts[1];
        this.monthIndex[key] = (this.monthIndex[key] || 0) + 1;
        this.yearSet.add(parseInt(parts[0], 10));
      }
      this.years = Array.from(this.yearSet).sort();

      // Set initial month from maxDate
      if (this.maxDate) {
        this.currentYear = this.maxDate.getFullYear();
        this.currentMonth = this.maxDate.getMonth();
      } else {
        var now = new Date();
        this.currentYear = now.getFullYear();
        this.currentMonth = now.getMonth();
      }

      // Smart init: if starting month has no puzzles, walk backward to find one
      var startKey = this.currentYear + '-' + pad(this.currentMonth + 1);
      if (!this.monthIndex[startKey] && dates.length > 0) {
        for (var j = 0; j < 60; j++) {
          this.currentMonth--;
          if (this.currentMonth < 0) { this.currentMonth = 11; this.currentYear--; }
          var k = this.currentYear + '-' + pad(this.currentMonth + 1);
          if (this.monthIndex[k]) break;
        }
      }

      this.render();
    }

    prev() {
      var year = this.currentYear;
      var month = this.currentMonth;

      // Walk backward up to 60 months to find one with puzzles
      for (var i = 0; i < 60; i++) {
        month--;
        if (month < 0) { month = 11; year--; }
        if (!this.canNavigate(year, month, 'prev')) return;
        var key = year + '-' + pad(month + 1);
        if (this.monthIndex[key]) {
          this.currentYear = year;
          this.currentMonth = month;
          this.render();
          return;
        }
      }
    }

    next() {
      var year = this.currentYear;
      var month = this.currentMonth;

      // Walk forward up to 60 months to find one with puzzles
      for (var i = 0; i < 60; i++) {
        month++;
        if (month > 11) { month = 0; year++; }
        if (!this.canNavigate(year, month, 'next')) return;
        var key = year + '-' + pad(month + 1);
        if (this.monthIndex[key]) {
          this.currentYear = year;
          this.currentMonth = month;
          this.render();
          return;
        }
      }
    }

    jumpToYear(event) {
      var year = parseInt(event.currentTarget.dataset.year, 10);
      // Find first month in this year with puzzles
      for (var m = 0; m < 12; m++) {
        var key = year + '-' + pad(m + 1);
        if (this.monthIndex[key]) {
          this.currentYear = year;
          this.currentMonth = m;
          this.render();
          return;
        }
      }
      // Fallback: January of that year
      this.currentYear = year;
      this.currentMonth = 0;
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

    // Check if there's a month with puzzles in the given direction
    hasPuzzleMonth(direction) {
      var year = this.currentYear;
      var month = this.currentMonth;

      for (var i = 0; i < 60; i++) {
        if (direction === 'prev') {
          month--;
          if (month < 0) { month = 11; year--; }
          if (!this.canNavigate(year, month, 'prev')) return false;
        } else {
          month++;
          if (month > 11) { month = 0; year++; }
          if (!this.canNavigate(year, month, 'next')) return false;
        }
        var key = year + '-' + pad(month + 1);
        if (this.monthIndex[key]) return true;
      }
      return false;
    }

    render() {
      var year = this.currentYear;
      var month = this.currentMonth;
      var firstDay = new Date(year, month, 1);
      var daysInMonth = new Date(year, month + 1, 0).getDate();
      // JS getDay(): 0=Sun..6=Sat. Convert to Mon-based: Mon=0..Sun=6
      var startOffset = (firstDay.getDay() + 6) % 7;

      // Can we navigate prev/next (to a month with puzzles)?
      var canPrev = this.hasPuzzleMonth('prev');
      var canNext = this.hasPuzzleMonth('next');

      // Puzzle count for current month
      var monthKey = year + '-' + pad(month + 1);
      var count = this.monthIndex[monthKey] || 0;
      var countLabel = count === 1 ? '1 puzzle' : count + ' puzzles';

      var html = '';

      // Year navigation bar
      if (this.years.length > 0) {
        html += '<div class="xw-calendar__years">';
        for (var y = 0; y < this.years.length; y++) {
          var yr = this.years[y];
          var isActive = yr === year;
          html += '<button class="xw-calendar__year-btn' +
                  (isActive ? ' xw-calendar__year-btn--active' : '') +
                  '" data-action="click->calendar#jumpToYear" data-year="' + yr + '">' +
                  yr + '</button>';
        }
        html += '</div>';
      }

      // Month navigation
      html += '<div class="xw-calendar__nav">';
      html += '<button class="xw-btn xw-btn--ghost" data-action="click->calendar#prev"' +
              (canPrev ? '' : ' disabled') + '>\u2039</button>';
      html += '<h3 class="xw-calendar__title">' + MONTH_NAMES[month] + ' ' + year +
              ' <span class="xw-calendar__count">(' + countLabel + ')</span></h3>';
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
