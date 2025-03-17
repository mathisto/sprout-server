import { Controller } from "@hotwired/stimulus"
import Chart from "chart.js/auto"

export default class extends Controller {
  static targets = ["canvas"]
  static values = {
    readings: Array,
    days: { type: Number, default: 7 }
  }
  
  connect() {
    if (!this.hasCanvasTarget) return
    
    const ctx = this.canvasTarget.getContext('2d')
    
    if (this.readingsValue.length === 0) return
    
    // Format data for the chart
    const data = this.readingsValue.map((reading, index) => ({
      x: index, // Use index for x to create a simple trend
      y: reading
    }))
    
    // Determine color based on latest reading
    const latestReading = this.readingsValue[this.readingsValue.length - 1]
    let color = 'rgb(59, 130, 246)' // Default blue
    
    if (latestReading < 30) {
      color = 'rgb(239, 68, 68)' // Red for dry
    } else if (latestReading > 70) {
      color = 'rgb(16, 185, 129)' // Green for wet
    }
    
    this.chart = new Chart(ctx, {
      type: 'line',
      data: {
        datasets: [{
          data: data,
          backgroundColor: `${color}20`,
          borderColor: color,
          borderWidth: 2,
          pointRadius: 0,
          tension: 0.4,
          fill: true
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: false
          },
          tooltip: {
            enabled: false
          }
        },
        scales: {
          x: {
            display: false
          },
          y: {
            display: false,
            min: 0,
            max: 100
          }
        },
        elements: {
          point: {
            radius: 0
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