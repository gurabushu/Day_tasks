
import { Controller } from "@hotwired/stimulus"
import Chart from "chart.js"

export default class extends Controller {
  static targets = ["canvas"]
  static values = { 
    type: String,
    data: Object,
    options: Object 
  }

  connect() {
    this.createChart()
  }

  disconnect() {
    if (this.chart) {
      this.chart.destroy()
    }
  }

  createChart() {
    const ctx = this.canvasTarget.getContext('2d')
    
    this.chart = new Chart(ctx, {
      type: this.typeValue,
      data: this.dataValue,
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            position: 'top',
          },
          title: {
            display: true,
            text: this.optionsValue.title || ''
          }
        },
        scales: this.getScales(),
        ...this.optionsValue
      }
    })
  }

  getScales() {
    if (this.typeValue === 'pie' || this.typeValue === 'doughnut') {
      return {}
    }
    
    return {
      y: {
        beginAtZero: true,
        ticks: {
          precision: 0
        }
      }
    }
  }
}