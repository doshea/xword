;(function () {
  class StatsController extends Stimulus.Controller {
    connect() {
      this.renderCharts()
    }

    renderCharts() {
      this.canvasTargets.forEach(canvas => this.renderChart(canvas))
    }

    renderChart(canvas) {
      var labels = JSON.parse(canvas.dataset.labels)
      var values = JSON.parse(canvas.dataset.values)
      var label  = canvas.dataset.chartLabel

      // Design token colors — forest green (--color-accent: #3a7d5c)
      var fill   = 'rgba(58, 125, 92, 0.15)'
      var stroke = 'rgba(58, 125, 92, 1)'

      new Chart(canvas, {
        type: 'line',
        data: {
          labels: labels,
          datasets: [{
            label: label,
            data: values,
            backgroundColor: fill,
            borderColor: stroke,
            borderWidth: 2,
            pointRadius: 0,
            pointHitRadius: 8,
            fill: true,
            tension: 0.3
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: true,
          animation: false,
          plugins: {
            legend: { display: false },
            tooltip: {
              backgroundColor: 'rgba(30, 28, 25, 0.9)',
              titleFont: { family: "'DM Sans', sans-serif" },
              bodyFont: { family: "'DM Sans', sans-serif" }
            }
          },
          scales: {
            x: {
              grid: { display: false },
              ticks: {
                font: { family: "'DM Sans', sans-serif", size: 11 },
                maxRotation: 45
              }
            },
            y: {
              beginAtZero: true,
              grid: { color: 'rgba(0, 0, 0, 0.06)' },
              ticks: {
                font: { family: "'DM Sans', sans-serif", size: 11 }
              }
            }
          }
        }
      })
    }
  }

  StatsController.targets = ['canvas']
  window.StimulusApp.register('stats', StatsController)
})()
