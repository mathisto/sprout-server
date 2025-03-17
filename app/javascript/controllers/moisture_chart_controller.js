import { Controller } from "@hotwired/stimulus"
import Chart from "chart.js/auto"

export default class extends Controller {
  static targets = ["canvas"]
  
  connect() {
    if (!this.hasCanvasTarget) return
    
    const ctx = this.canvasTarget.getContext('2d')
    const data = JSON.parse(this.element.dataset.readings || '[]')
    
    if (data.length === 0) return
    
    this.chart = new Chart(ctx, {
      type: 'line',
      data: {
        datasets: [{
          label: 'Moisture (%)',
          data: data.map(reading => ({
            x: new Date(reading.recorded_at),
            y: reading.moisture_level
          })),
          backgroundColor: 'rgba(16, 185, 129, 0.2)',
          borderColor: 'rgb(16, 185, 129)',
          borderWidth: 2,
          pointRadius: 3,
          tension: 0.3
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
          x: {
            type: 'time',
            time: {
              unit: 'day',
              displayFormats: {
                day: 'MMM dd'
              }
            },
            title: {
              display: true,
              text: 'Date'
            }
          },
          y: {
            min: 0,
            max: 100,
            title: {
              display: true,
              text: 'Moisture (%)'
            }
          }
        },
        plugins: {
          tooltip: {
            callbacks: {
              title: (context) => {
                const date = new Date(context[0].parsed.x)
                return date.toLocaleString()
              }
            }
          }
        }
      }
    })
  }
  
  disconnect() {
    if (this.chart) {
      this.chart.destroy()
    }
  }
} 