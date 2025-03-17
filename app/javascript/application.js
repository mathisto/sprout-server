// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
console.log("🚀 Application JS initialized - Using HTMX for live updates")

// We're now using HTMX for live updates, so we don't need these:
// import "@rails/actioncable"
// import "@hotwired/turbo-rails"
// import "controllers"
// import "channels"

// Log when the DOM is fully loaded
document.addEventListener("DOMContentLoaded", () => {
  console.log("🌐 DOM fully loaded")
})
