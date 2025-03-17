# Plant Moisture Monitoring System - Developer Specification

## Executive Summary

This document outlines the complete specification for a Rails 8.02 application designed to monitor plant moisture levels from ESP32 devices. The system will receive moisture readings via a JSON API, store historical data, and provide a real-time dashboard for monitoring plant health with trends visualization. The application follows Rails 8 best practices including Propshaft, Hotwire, and HTMX for real-time updates without React.

## 1. Requirements

### 1.1 Functional Requirements

- Receive moisture readings from ESP32 devices via HTTP REST endpoint
- Store moisture readings in a database with historical tracking
- Display a dashboard with all plants and their current moisture levels
- Show moisture trends over time with line graphs
- Allow users to view detailed information for each plant
- Enable users to set preferred moisture ranges for each plant
- Provide visual status indicators based on moisture levels
- Support CRUD operations for plant information management
- Implement real-time updates for the dashboard without page reloads

### 1.2 Non-Functional Requirements

- Follow Rails 8.02 best practices and philosophy
- Use Propshaft (not Sprockets) for asset pipeline
- Employ Hotwire (Turbo & Stimulus) for real-time features
- Use HTMX for dynamic content where appropriate (not React)
- Implement the Tokyo Night color scheme for UI
- Store all historical data indefinitely
- Ensure the application is performant with large datasets
- Design responsive UI for various screen sizes

## 2. System Architecture

### 2.1 Technology Stack

- **Framework**: Ruby on Rails 8.02
- **Ruby Version**: 3.3+
- **Database**: PostgreSQL 14+
- **Asset Pipeline**: Propshaft (Rails 8 default)
- **Frontend Technologies**:
  - Hotwire (Turbo & Stimulus) for real-time updates
  - HTMX for enhanced UI interactions
  - TailwindCSS for styling
  - Chart.js for visualizations
- **Real-time Updates**: Turbo Streams with ActionCable
- **Testing**: RSpec, Factory Bot, Capybara

### 2.2 System Components

1. **Data Ingestion Service**: API endpoint to receive moisture readings
2. **Data Storage Layer**: PostgreSQL database for persistent storage
3. **Business Logic Layer**: Rails models and services
4. **Presentation Layer**: Rails views with Hotwire and HTMX
5. **Development Utilities**: Rake tasks for generating test data

### 2.3 Data Flow

1. ESP32 devices send moisture readings to the API endpoint
2. The application processes the reading and stores it in the database
3. Turbo Streams broadcast the update to all connected clients
4. The dashboard updates in real-time to show the new moisture level
5. Historical data is available for trend analysis and visualization

## 3. Database Schema

### 3.1 Plants Table

```ruby
create_table "plants", force: :cascade do |t|
  t.string "slug", null: false
  t.string "species"
  t.string "location"
  t.integer "preferred_moisture_min"
  t.integer "preferred_moisture_max"
  t.text "care_notes"
  t.timestamps
end

add_index "plants", ["slug"], name: "index_plants_on_slug", unique: true
```

### 3.2 Moisture Readings Table

```ruby
create_table "moisture_readings", force: :cascade do |t|
  t.references "plant", null: false, foreign_key: true, index: true
  t.integer "moisture_level", null: false
  t.datetime "recorded_at", null: false, index: true
  t.timestamps
end
```

## 4. API Specification

### 4.1 Moisture Reading Endpoint

**Endpoint**: `POST /api/readings`

**Request Format**:
```json
{
  "id": 1,           // integer: device/plant ID
  "slug": "monstera", // string: human-readable plant name
  "moisture": 75      // integer: moisture level (0-100)
}
```

**Response Format (Success)**:
```json
{
  "success": true,
  "reading_id": 42,
  "timestamp": "2025-03-16T15:30:45Z"
}
```

**Response Format (Error)**:
```json
{
  "success": false,
  "errors": ["Moisture level must be between 0 and 100"]
}
```

**Status Codes**:
- 201: Created (successful reading creation)
- 400: Bad Request (invalid parameters)
- 422: Unprocessable Entity (validation errors)
- 500: Internal Server Error

## 5. Models Implementation

### 5.1 Plant Model

```ruby
# app/models/plant.rb
class Plant < ApplicationRecord
  has_many :moisture_readings, dependent: :destroy
  
  validates :slug, presence: true, uniqueness: true
  
  # Optional validations for better data integrity
  validates :preferred_moisture_min, numericality: { 
    only_integer: true, 
    greater_than_or_equal_to: 0, 
    less_than_or_equal_to: 100,
    allow_nil: true
  }
  
  validates :preferred_moisture_max, numericality: { 
    only_integer: true, 
    greater_than_or_equal_to: 0, 
    less_than_or_equal_to: 100,
    allow_nil: true
  }
  
  validate :moisture_range_is_valid
  
  def current_moisture
    moisture_readings.order(recorded_at: :desc).first&.moisture_level
  end
  
  def moisture_status
    return :unknown if current_moisture.nil?
    
    if preferred_moisture_min.present? && preferred_moisture_max.present?
      if current_moisture < preferred_moisture_min
        :too_dry
      elsif current_moisture > preferred_moisture_max
        :too_wet
      else
        :ideal
      end
    else
      :unknown
    end
  end
  
  def recent_readings(limit = 24)
    moisture_readings.order(recorded_at: :desc).limit(limit).reverse
  end
  
  def readings_for_chart(days: 7)
    moisture_readings
      .where('recorded_at >= ?', days.days.ago)
      .order(recorded_at: :asc)
  end
  
  private
  
  def moisture_range_is_valid
    return unless preferred_moisture_min.present? && preferred_moisture_max.present?
    
    if preferred_moisture_min >= preferred_moisture_max
      errors.add(:preferred_moisture_min, "must be less than maximum moisture")
    end
  end
end
```

### 5.2 Moisture Reading Model

```ruby
# app/models/moisture_reading.rb
class MoistureReading < ApplicationRecord
  belongs_to :plant
  
  validates :moisture_level, presence: true, 
            numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :recorded_at, presence: true
end
```

## 6. Controllers Implementation

### 6.1 Dashboard Controller

```ruby
# app/controllers/dashboard_controller.rb
class DashboardController < ApplicationController
  def index
    @plants = Plant.all.includes(:moisture_readings)
  end
end
```

### 6.2 Plants Controller

```ruby
# app/controllers/plants_controller.rb
class PlantsController < ApplicationController
  before_action :set_plant, only: [:show, :edit, :update, :destroy]
  
  def index
    @plants = Plant.all
  end
  
  def show
    @readings = @plant.readings_for_chart
  end
  
  def new
    @plant = Plant.new
  end
  
  def create
    @plant = Plant.new(plant_params)
    
    if @plant.save
      redirect_to @plant, notice: 'Plant was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
  end
  
  def update
    if @plant.update(plant_params)
      redirect_to @plant, notice: 'Plant was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @plant.destroy
    redirect_to plants_url, notice: 'Plant was successfully destroyed.'
  end
  
  private
  
  def set_plant
    @plant = Plant.find(params[:id])
  end
  
  def plant_params
    params.require(:plant).permit(:slug, :species, :location, 
                                 :preferred_moisture_min, :preferred_moisture_max, 
                                 :care_notes)
  end
end
```

### 6.3 API Readings Controller

```ruby
# app/controllers/api/readings_controller.rb
class Api::ReadingsController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def create
    # Find or create plant based on ID and slug
    plant = Plant.find_or_create_by(id: params[:id]) do |p|
      p.slug = params[:slug] if params[:slug].present?
    end
    
    reading = plant.moisture_readings.new(
      moisture_level: params[:moisture],
      recorded_at: Time.current
    )
    
    if reading.save
      # Broadcast update to all connected clients
      broadcast_update(plant)
      
      render json: { 
        success: true, 
        reading_id: reading.id,
        timestamp: reading.recorded_at 
      }, status: :created
    else
      render json: { 
        success: false, 
        errors: reading.errors.full_messages 
      }, status: :unprocessable_entity
    end
  rescue StandardError => e
    Rails.logger.error("API Error: #{e.message}")
    render json: { 
      success: false, 
      errors: ["An unexpected error occurred: #{e.message}"] 
    }, status: :internal_server_error
  end
  
  private
  
  def broadcast_update(plant)
    Turbo::StreamsChannel.broadcast_replace_to(
      "dashboard",
      target: "plant_#{plant.id}",
      partial: "plants/plant_card",
      locals: { plant: plant }
    )
  end
end
```

## 7. Views Implementation

### 7.1 Application Layout

```erb
<%# app/views/layouts/application.html.erb %>
<!DOCTYPE html>
<html>
  <head>
    <title>Plant Moisture Monitor</title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    <%= stylesheet_link_tag "tailwind", "inter-font", "data-turbo-track": "reload" %>
    <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
    <%= javascript_importmap_tags %>
  </head>

  <body class="bg-primary text-primary">
    <header class="bg-secondary border-b border-border py-4">
      <div class="container mx-auto px-4">
        <div class="flex justify-between items-center">
          <h1 class="text-xl font-bold">
            <%= link_to "Plant Moisture Monitor", root_path %>
          </h1>
          <nav>
            <%= link_to "Plants", plants_path, class: "text-accent-blue hover:text-accent-cyan ml-4" %>
          </nav>
        </div>
      </div>
    </header>

    <main>
      <% if notice %>
        <div class="bg-success bg-opacity-20 text-success px-4 py-2">
          <%= notice %>
        </div>
      <% end %>
      
      <% if alert %>
        <div class="bg-error bg-opacity-20 text-error px-4 py-2">
          <%= alert %>
        </div>
      <% end %>

      <%= yield %>
    </main>

    <footer class="bg-secondary border-t border-border py-4 mt-8">
      <div class="container mx-auto px-4 text-center text-secondary">
        <p>Plant Moisture Monitor &copy; <%= Date.current.year %></p>
      </div>
    </footer>
  </body>
</html>
```

### 7.2 Dashboard View

```erb
<%# app/views/dashboard/index.html.erb %>
<div class="container mx-auto py-6 px-4">
  <div class="flex justify-between items-center mb-6">
    <h1 class="text-2xl font-bold">Dashboard</h1>
    <%= link_to "Add New Plant", new_plant_path, class: "bg-accent-blue hover:bg-accent-cyan text-white px-4 py-2 rounded" %>
  </div>
  
  <%= turbo_stream_from "dashboard" %>
  
  <% if @plants.empty? %>
    <div class="bg-secondary rounded-lg shadow-lg p-8 text-center">
      <p class="text-xl mb-4">No plants added yet!</p>
      <p class="mb-4">Add your first plant to start monitoring moisture levels.</p>
      <%= link_to "Add Plant", new_plant_path, class: "bg-accent-blue hover:bg-accent-cyan text-white px-4 py-2 rounded" %>
    </div>
  <% else %>
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
      <%= render partial: "plants/plant_card", collection: @plants, as: :plant %>
    </div>
  <% end %>
</div>
```

### 7.3 Plant Card Partial

```erb
<%# app/views/plants/_plant_card.html.erb %>
<div id="plant_<%= plant.id %>" class="bg-secondary rounded-lg shadow-lg overflow-hidden">
  <div class="p-4">
    <div class="flex justify-between items-center mb-2">
      <h2 class="text-xl font-bold"><%= plant.slug %></h2>
      <span class="text-sm px-2 py-1 rounded
        <%= case plant.moisture_status
            when :too_dry
              'bg-error bg-opacity-20 text-error'
            when :too_wet
              'bg-error bg-opacity-20 text-error'
            when :ideal
              'bg-success bg-opacity-20 text-success'
            else
              'bg-info bg-opacity-20 text-info'
            end %>">
        <%= plant.current_moisture || '?' %>%
      </span>
    </div>
    
    <% if plant.species.present? %>
      <p class="text-sm text-secondary mb-2"><%= plant.species %></p>
    <% end %>
    
    <% if plant.location.present? %>
      <p class="text-sm text-secondary mb-4"><%= plant.location %></p>
    <% end %>
    
    <div class="h-20 moisture-trend" 
         data-controller="trend"
         data-trend-readings-value="<%= plant.recent_readings.pluck(:moisture_level).to_json %>"></div>
    
    <div class="mt-4 text-right">
      <%= link_to "View Details", plant_path(plant), class: "text-accent-blue hover:text-accent-cyan" %>
    </div>
  </div>
</div>
```

### 7.4 Plant Show View

```erb
<%# app/views/plants/show.html.erb %>
<div class="container mx-auto py-6 px-4">
  <div class="flex justify-between items-center mb-6">
    <h1 class="text-2xl font-bold"><%= @plant.slug %></h1>
    <%= link_to "Back to Dashboard", root_path, class: "text-accent-blue hover:text-accent-cyan" %>
  </div>
  
  <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
    <div class="lg:col-span-1 bg-secondary rounded-lg shadow-lg p-4">
      <h2 class="text-xl font-bold mb-4">Plant Details</h2>
      
      <div class="mb-4">
        <p class="text-sm text-secondary">Species</p>
        <p><%= @plant.species.presence || "Unknown" %></p>
      </div>
      
      <div class="mb-4">
        <p class="text-sm text-secondary">Location</p>
        <p><%= @plant.location.presence || "Not specified" %></p>
      </div>
      
      <div class="mb-4">
        <p class="text-sm text-secondary">Preferred Moisture Range</p>
        <% if @plant.preferred_moisture_min.present? && @plant.preferred_moisture_max.present? %>
          <p><%= @plant.preferred_moisture_min %>% - <%= @plant.preferred_moisture_max %>%</p>
        <% else %>
          <p>Not set</p>
        <% end %>
      </div>
      
      <div class="mb-4">
        <p class="text-sm text-secondary">Current Status</p>
        <p>
          <span class="inline-block px-2 py-1 rounded
            <%= case @plant.moisture_status
                when :too_dry
                  'bg-error bg-opacity-20 text-error'
                when :too_wet
                  'bg-error bg-opacity-20 text-error'
                when :ideal
                  'bg-success bg-opacity-20 text-success'
                else
                  'bg-info bg-opacity-20 text-info'
                end %>">
            <%= @plant.moisture_status.to_s.humanize %>
          </span>
        </p>
      </div>
      
      <div class="mb-4">
        <p class="text-sm text-secondary">Care Notes</p>
        <p class="whitespace-pre-line"><%= @plant.care_notes.presence || "No notes" %></p>
      </div>
      
      <div class="mt-6 flex space-x-4">
        <%= link_to "Edit", edit_plant_path(@plant), class: "text-accent-blue hover:text-accent-cyan" %>
        <%= button_to "Delete", plant_path(@plant), method: :delete, 
                     data: { turbo_confirm: "Are you sure you want to delete this plant?" }, 
                     class: "text-error hover:text-opacity-80" %>
      </div>
    </div>
    
    <div class="lg:col-span-2 bg-secondary rounded-lg shadow-lg p-4">
      <h2 class="text-xl font-bold mb-4">Moisture History</h2>
      
      <div class="h-96 moisture-history" 
           data-controller="charts" 
           data-charts-readings-value="<%= @readings.to_json(only: [:moisture_level, :recorded_at]) %>"
           data-charts-min-value="<%= @plant.preferred_moisture_min || 0 %>"
           data-charts-max-value="<%= @plant.preferred_moisture_max || 100 %>"></div>
    </div>
  </div>
</div>
```

### 7.5 Plant Form Partial

```erb
<%# app/views/plants/_form.html.erb %>
<%= form_with(model: plant, class: "space-y-4") do |form| %>
  <% if plant.errors.any? %>
    <div class="bg-error bg-opacity-20 p-4 rounded">
      <h2 class="text-error font-bold mb-2"><%= pluralize(plant.errors.count, "error") %> prohibited this plant from being saved:</h2>
      <ul class="list-disc pl-5">
        <% plant.errors.each do |error| %>
          <li class="text-error"><%= error.full_message %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <div>
    <%= form.label :slug, class: "block text-sm font-medium" %>
    <%= form.text_field :slug, class: "mt-1 block w-full rounded border-border bg-primary text-primary p-2" %>
    <p class="mt-1 text-sm text-secondary">A unique identifier for this plant (e.g., monstera_living_room)</p>
  </div>

  <div>
    <%= form.label :species, class: "block text-sm font-medium" %>
    <%= form.text_field :species, class: "mt-1 block w-full rounded border-border bg-primary text-primary p-2" %>
  </div>

  <div>
    <%= form.label :location, class: "block text-sm font-medium" %>
    <%= form.text_field :location, class: "mt-1 block w-full rounded border-border bg-primary text-primary p-2" %>
  </div>

  <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
    <div>
      <%= form.label :preferred_moisture_min, "Minimum Moisture (%)", class: "block text-sm font-medium" %>
      <%= form.number_field :preferred_moisture_min, min: 0, max: 100, class: "mt-1 block w-full rounded border-border bg-primary text-primary p-2" %>
    </div>

    <div>
      <%= form.label :preferred_moisture_max, "Maximum Moisture (%)", class: "block text-sm font-medium" %>
      <%= form.number_field :preferred_moisture_max, min: 0, max: 100, class: "mt-1 block w-full rounded border-border bg-primary text-primary p-2" %>
    </div>
  </div>

  <div>
    <%= form.label :care_notes, class: "block text-sm font-medium" %>
    <%= form.text_area :care_notes, rows: 4, class: "mt-1 block w-full rounded border-border bg-primary text-primary p-2" %>
  </div>

  <div class="flex justify-end">
    <%= form.submit class: "bg-accent-blue hover:bg-accent-cyan text-white px-4 py-2 rounded" %>
  </div>
<% end %>
```

## 8. JavaScript Components

### 8.1 Stimulus Controllers

```javascript
// app/javascript/controllers/charts_controller.js
import { Controller } from "@hotwired/stimulus"
import Chart from "chart.js/auto"

export default class extends Controller {
  static values = {
    readings: Array,
    min: { type: Number, default: 0 },
    max: { type: Number, default: 100 }
  }
  
  connect() {
    this.initializeChart()
  }
  
  disconnect() {
    if (this.chart) {
      this.chart.destroy()
    }
  }
  
  initializeChart() {
    if (!this.hasReadingsValue || this.readingsValue.length === 0) {
      this.showNoDataMessage()
      return
    }
    
    const ctx = document.createElement("canvas")
    this.element.appendChild(ctx)
    
    const data = this.readingsValue.map(reading => ({
      x: new Date(reading.recorded_at),
      y: reading.moisture_level
    }))
    
    const minValue = this.minValue
    const maxValue = this.maxValue
    
    this.chart = new Chart(ctx, {
      type: "line",
      data: {
        datasets: [{
          label: "Moisture Level",
          data: data,
          borderColor: "#7aa2f7",
          backgroundColor: "rgba(122, 162, 247, 0.1)",
          tension: 0.2,
          pointRadius: 3,
          pointBackgroundColor: "#7dcfff"
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
          x: {
            type: "time",
            time: {
              unit: "hour",
              displayFormats: {
                hour: "MMM d, h:mm a"
              }
            },
            grid: {
              color: "rgba(166, 172, 205, 0.1)"
            },
            ticks: {
              color: "#787c99"
            }
          },
          y: {
            min: 0,
            max: 100,
            grid: {
              color: "rgba(166, 172, 205, 0.1)"
            },
            ticks: {
              color: "#787c99"
            }
          }
        },
        plugins: {
          legend: {
            labels: {
              color: "#a9b1d6"
            }
          },
          tooltip: {
            backgroundColor: "#16161e",
            titleColor: "#a9b1d6",
            bodyColor: "#c0caf5",
            borderColor: "#3d59a1",
            borderWidth: 1
          },
          annotation: {
            annotations: {
              minLine: minValue ? {
                type: 'line',
                yMin: minValue,
                yMax: minValue,
                borderColor: '#e0af68',
                borderWidth: 1,
                borderDash: [5, 5],
                label: {
                  content: `Min (${minValue}%)`,
                  enabled: true,
                  position: 'left',
                  backgroundColor: 'rgba(224, 175, 104, 0.8)'
                }
              } : undefined,
              maxLine: maxValue ? {
                type: 'line',
                yMin: maxValue,
                yMax: maxValue,
                borderColor: '#e0af68',
                borderWidth: 1,
                borderDash: [5, 5],
                label: {
                  content: `Max (${maxValue}%)`,
                  enabled: true,
                  position: 'left',
                  backgroundColor: 'rgba(224, 175, 104, 0.8)'
                }
              } : undefined
            }
          }
        }
      }
    })
  }
  
  showNoDataMessage() {
    this.element.innerHTML = `
      <div class="flex items-center justify-center h-full">
        <p class="text-secondary">No moisture data available yet</p>
      </div>
    `
  }
}

// app/javascript/controllers/trend_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    readings: Array
  }
  
  connect() {
    this.drawTrendLine()
  }
  
  drawTrendLine() {
    const readings = this.readingsValue
    
    if (!readings || readings.length === 0) {
      this.element.innerHTML = `
        <div class="flex items-center justify-center h-full">
          <p class="text-sm text-secondary">No data</p>
        </div>
      `
      return
    }
    
    const canvas = document.createElement("canvas")
    canvas.width = this.element.clientWidth
    canvas.height = this.element.clientHeight
    this.element.innerHTML = ''
    this.element.appendChild(canvas)
    
    const ctx = canvas.getContext("2d")
    
    // Draw trend line
    const width = canvas.width
    const height = canvas.height
    const stepX = width / (readings.length - 1 || 1)
    
    ctx.strokeStyle = "#7aa2f7"
    ctx.lineWidth = 2
    ctx.beginPath()
    
    readings.forEach((reading, index) => {
      const x = index * stepX
      const y = height - (reading / 100 * height)
      
      if (index === 0) {
        ctx.moveTo(x, y)
      } else {
        ctx.lineTo(x, y)
      }
    })
    
    ctx.stroke()
    
    // Add dots for each reading
    readings.forEach((reading, index) => {
      const x = index * stepX
      const y = height - (reading / 100 * height)
      
      ctx.fillStyle = "#7dcfff"
      ctx.beginPath()
      ctx.arc(x, y, 3, 0, Math.PI * 2)
      ctx.fill()
    })
    
    // Add the latest reading as text
    const latestReading = readings[readings.length - 1]
    ctx.fillStyle = "#a9b1d6"
    ctx.font = "12px sans-serif"
    ctx.textAlign = "right"
    ctx.fillText(`${latestReading}%`, width - 5, 15)
  }
}
```

### 8.2 CSS Theming

```css
/* app/assets/stylesheets/application.tailwind.css */
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    --color-primary-bg: 26, 27, 38;      /* #1a1b26 */
    --color-secondary-bg: 22, 22, 30;    /* #16161e */
    --color-primary-text: 169, 177, 214; /* #a9b1d6 */
    --color-secondary-text: 120, 124, 153; /* #787c99 */
    --color-border: 61, 89, 161;         /* #3d59a1 */
    
    --color-accent-blue: 122, 162, 247;  /* #7aa2f7 */
    --color-accent-cyan: 125, 207, 255;  /* #7dcfff */
    --color-accent-green: 115, 218, 202; /* #73daca */
    --color-accent-purple: 187, 154, 247; /* #bb9af7 */
    --color-accent-red: 247, 118, 142;   /* #f7768e */
    --color-accent-yellow: 224, 175, 104; /* #e0af68 */
    --color-accent-orange: 255, 158, 100; /* #ff9e64 */
    
    --color-success: 158, 206, 106;      /* #9ece6a */
    --color-warning: 224, 175, 104;      /* #e0af68 */
    --color-error: 219, 75, 75;          /* #db4b4b */
    --color-info: 13, 185, 215;          /* #0db9d7 */
  }
}

@layer components {
  .bg-primary {
    @apply bg-[rgb(var(--color-primary-bg))];
  }
  
  .bg-secondary {
    @apply bg-[rgb(var(--color-secondary-bg))];
  }
  
  .text-primary {
    @apply text-[rgb(var(--color-primary-text))];
  }
  
  .text-secondary {
    @apply text-[rgb(var(--color-secondary-text))];
  }
  
  .border-border {
    @apply border-[rgb(var(--color-border))];
  }
  
  .text-accent-blue {
    @apply text-[rgb(var(--color-accent-blue))];
  }
  
  .text-accent-cyan {
    @apply text-[rgb(var(--color-accent-cyan))];
  }
  
  .bg-accent-blue {
    @apply bg-[rgb(var(--color-accent-blue))];
  }
  
  .bg-accent-cyan {
    @apply bg-[rgb(var(--color-accent-cyan))];
  }
  
  .text-success {
    @apply text-[rgb(var(--color-success))];
  }
  
  .bg-success {
    @apply bg-[rgb(var(--color-success))];
  }
  
  .text-warning {
    @apply text-[rgb(var(--color-warning))];
  }
  
  .bg-warning {
    @apply bg-[rgb(var(--color-warning))];
  }
  
  .text-error {
    @apply text-[rgb(var(--color-error))];
  }
  
  .bg-error {
    @apply bg-[rgb(var(--color-error))];
  }
  
  .text-info {
    @apply text-[rgb(var(--color-info))];
  }
  
  .bg-info {
    @apply bg-[rgb(var(--color-info))];
  }
}
```

## 9. Routes Configuration

```ruby
# config/routes.rb
Rails.application.routes.draw do
  root "dashboard#index"
  
  resources :plants
  
  namespace :api do
    resources :readings, only: [:create]
  end
end
```

## 10. Development Tools

### 10.1 Mock Data Generator

```ruby
# lib/tasks/mock_data.rake
namespace :plants do
  desc "Generate mock moisture readings"
  task generate_readings: :environment do
    plants = Plant.all
    
    if plants.empty?
      puts "No plants found. Creating sample plants..."
      [
        { name: "Monstera", min: 30, max: 60 },
        { name: "Snake Plant", min: 20, max: 40 },
        { name: "Pothos", min: 25, max: 50 },
        { name: "Fiddle Leaf Fig", min: 40, max: 70 }
      ].each do |plant_data|
        Plant.create!(
          slug: plant_data[:name].downcase.gsub(" ", "_"),
          species: plant_data[:name],
          location: ["Living Room", "Bedroom", "Kitchen", "Office"].sample,
          preferred_moisture_min: plant_data[:min],
          preferred_moisture_max: plant_data[:max],
          care_notes: "Sample care notes for #{plant_data[:name]}"
        )
      end
      plants = Plant.all
    end
    
    puts "Generating readings for #{plants.count} plants..."
    
    plants.each do |plant|
      # Generate a realistic moisture pattern
      base_moisture = rand(30..70)
      fluctuation = rand(5..15)
      
      # Create a reading for the current time
      current_moisture = [0, [base_moisture + rand(-fluctuation..fluctuation), 100].min].max
      
      plant.moisture_readings.create!(
        moisture_level: current_moisture,
        recorded_at: Time.current
      )
      
      puts "Added reading for #{plant.slug}: #{current_moisture}%"
    end
    
    puts "Done!"
  end
  
  desc "Generate mock historical data"
  task generate_history: :environment do
    plants = Plant.all
    
    if plants.empty?
      puts "No plants found. Run 'rails plants:generate_readings' first."
      next
    }
    
    days_back = ENV.fetch("DAYS", "7").to_i
    readings_per_day = ENV.fetch("READINGS_PER_DAY", "24").to_i
    
    puts "Generating #{readings_per_day} readings per day for the past #{days_back} days..."
    
    plants.each do |plant|
      puts "Generating history for #{plant.slug}..."
      
      # Set base moisture level and trend direction for this plant
      base_moisture = rand(30..70)
      trend_direction = rand(-1..1) # -1: decreasing, 0: stable, 1: increasing
      
      # Generate readings for each day
      (days_back.days.ago.to_date..Date.yesterday).each do |date|
        # Slightly adjust base moisture based on trend
        base_moisture += trend_direction * rand(0..2)
        base_moisture = [10, [base_moisture, 90].min].max # Keep within reasonable bounds
        
        # Generate readings throughout the day
        readings_per_day.times do |i|
          # Calculate time for this reading (distribute throughout the day)
          hours_offset = (24.0 / readings_per_day) * i
          timestamp = date.to_time + hours_offset.hours
          
          # Add some random fluctuation
          fluctuation = rand(-10..10)
          moisture = [0, [base_moisture + fluctuation, 100].min].max
          
          plant.moisture_readings.create!(
            moisture_level: moisture,
            recorded_at: timestamp
          )
        end
      end
      
      puts "Generated #{readings_per_day * days_back} historical readings for #{plant.slug}"
    end
    
    puts "Done!"
  end
end
```

### 10.2 Database Configuration

```ruby
# config/database.yml
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: plant_monitor_development

test:
  <<: *default
  database: plant_monitor_test

production:
  <<: *default
  database: plant_monitor_production
  username: plant_monitor
  password: <%= ENV["PLANT_MONITOR_DATABASE_PASSWORD"] %>
```

## 11. Error Handling Strategy

### 11.1 Exception Handling

- Implement custom error pages for 404, 422, and 500 errors
- Use `rescue_from` in ApplicationController to handle common exceptions
- Log all errors with appropriate context for debugging
- Return meaningful error messages in API responses

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  
  private
  
  def not_found
    respond_to do |format|
      format.html { render file: "#{Rails.root}/public/404.html", status: :not_found }
      format.json { render json: { error: "Resource not found" }, status: :not_found }
      format.all { render plain: "404 Not Found", status: :not_found }
    end
  end
end
```

### 11.2 Client Error Handling

```javascript
// app/javascript/controllers/api_error_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["notification"]
  
  showError(message) {
    const notification = this.notificationTarget
    notification.textContent = message
    notification.classList.remove("hidden")
    
    setTimeout(() => {
      notification.classList.add("hidden")
    }, 5000)
  }
  
  // Handle API errors
  async handleApiRequest(url, options = {}) {
    try {
      const response = await fetch(url, options)
      
      if (!response.ok) {
        const data = await response.json()
        const errorMessage = data.errors?.join(", ") || "An error occurred"
        this.showError(errorMessage)
        return null
      }
      
      return await response.json()
    } catch (error) {
      this.showError("Network error: " + error.message)
      return null
    }
  }
}
```

## 12. Testing Plan

### 12.1 Test Suite Setup

```ruby
# Gemfile additional testing dependencies
group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'webmock'
  gem 'vcr'
  gem 'shoulda-matchers'
end
```

### 12.2 Model Tests

```ruby
# spec/models/plant_spec.rb
require 'rails_helper'

RSpec.describe Plant, type: :model do
  describe "validations" do
    it { should validate_presence_of(:slug) }
    it { should validate_uniqueness_of(:slug) }
    
    context "when preferred moisture range is specified" do
      let(:plant) { build(:plant, preferred_moisture_min: 60, preferred_moisture_max: 40) }
      
      it "validates that min is less than max" do
        expect(plant).not_to be_valid
        expect(plant.errors[:preferred_moisture_min]).to include("must be less than maximum moisture")
      end
    end
  end
  
  describe "associations" do
    it { should have_many(:moisture_readings).dependent(:destroy) }
  end
  
  describe "#current_moisture" do
    let(:plant) { create(:plant) }
    
    context "when plant has readings" do
      before do
        create(:moisture_reading, plant: plant, moisture_level: 50, recorded_at: 1.day.ago)
        create(:moisture_reading, plant: plant, moisture_level: 55, recorded_at: 1.hour.ago)
      end
      
      it "returns the moisture level of the most recent reading" do
        expect(plant.current_moisture).to eq(55)
      end
    end
    
    context "when plant has no readings" do
      it "returns nil" do
        expect(plant.current_moisture).to be_nil
      end
    end
  end
  
  describe "#moisture_status" do
    let(:plant) { create(:plant, preferred_moisture_min: 30, preferred_moisture_max: 60) }
    
    context "when moisture is below minimum" do
      before do
        create(:moisture_reading, plant: plant, moisture_level: 20)
      end
      
      it "returns :too_dry" do
        expect(plant.moisture_status).to eq(:too_dry)
      end
    end
    
    context "when moisture is above maximum" do
      before do
        create(:moisture_reading, plant: plant, moisture_level: 70)
      end
      
      it "returns :too_wet" do
        expect(plant.moisture_status).to eq(:too_wet)
      end
    end
    
    context "when moisture is within range" do
      before do
        create(:moisture_reading, plant: plant, moisture_level: 45)
      end
      
      it "returns :ideal" do
        expect(plant.moisture_status).to eq(:ideal)
      end
    end
    
    context "when no preferred range is set" do
      let(:plant_without_range) { create(:plant, preferred_moisture_min: nil, preferred_moisture_max: nil) }
      
      before do
        create(:moisture_reading, plant: plant_without_range, moisture_level: 45)
      end
      
      it "returns :unknown" do
        expect(plant_without_range.moisture_status).to eq(:unknown)
      end
    end
  end
end

# spec/models/moisture_reading_spec.rb
require 'rails_helper'

RSpec.describe MoistureReading, type: :model do
  describe "validations" do
    it { should validate_presence_of(:moisture_level) }
    it { should validate_presence_of(:recorded_at) }
    
    it { should validate_numericality_of(:moisture_level).only_integer.is_greater_than_or_equal_to(0).is_less_than_or_equal_to(100) }
  end
  
  describe "associations" do
    it { should belong_to(:plant) }
  end
end
```

### 12.3 Controller Tests

```ruby
# spec/controllers/api/readings_controller_spec.rb
require 'rails_helper'

RSpec.describe Api::ReadingsController, type: :controller do
  describe "POST #create" do
    context "with valid parameters" do
      let(:plant) { create(:plant) }
      let(:valid_params) { { id: plant.id, slug: plant.slug, moisture: 75 } }
      
      it "creates a new moisture reading" do
        expect {
          post :create, params: valid_params
        }.to change(MoistureReading, :count).by(1)
      end
      
      it "returns a success response" do
        post :create, params: valid_params
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)["success"]).to be true
      end
      
      it "broadcasts a Turbo Stream update" do
        expect(Turbo::StreamsChannel).to receive(:broadcast_replace_to)
        post :create, params: valid_params
      end
    end
    
    context "with invalid parameters" do
      let(:plant) { create(:plant) }
      let(:invalid_params) { { id: plant.id, slug: plant.slug, moisture: 101 } }
      
      it "does not create a new moisture reading" do
        expect {
          post :create, params: invalid_params
        }.not_to change(MoistureReading, :count)
      end
      
      it "returns an error response" do
        post :create, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["success"]).to be false
      end
    end
    
    context "when plant doesn't exist" do
      let(:new_plant_params) { { id: 9999, slug: "new_plant", moisture: 75 } }
      
      it "creates a new plant" do
        expect {
          post :create, params: new_plant_params
        }.to change(Plant, :count).by(1)
      end
      
      it "creates a new moisture reading" do
        expect {
          post :create, params: new_plant_params
        }.to change(MoistureReading, :count).by(1)
      end
      
      it "returns a success response" do
        post :create, params: new_plant_params
        expect(response).to have_http_status(:created)
      end
    end
  end
end
```

### 12.4 System Tests

```ruby
# spec/system/dashboard_spec.rb
require 'rails_helper'

RSpec.describe "Dashboard", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end
  
  context "with plants" do
    let!(:plant1) { create(:plant, slug: "monstera") }
    let!(:plant2) { create(:plant, slug: "snake_plant") }
    
    before do
      create(:moisture_reading, plant: plant1, moisture_level: 45)
      create(:moisture_reading, plant: plant2, moisture_level: 30)
      visit root_path
    end
    
    it "displays all plants" do
      expect(page).to have_content("monstera")
      expect(page).to have_content("snake_plant")
    end
    
    it "displays current moisture levels" do
      expect(page).to have_content("45%")
      expect(page).to have_content("30%")
    end
    
    it "links to plant details pages" do
      click_link "View Details", match: :first
      expect(page).to have_content("Plant Details")
    end
  end
  
  context "without plants" do
    before do
      visit root_path
    end
    
    it "displays a message about no plants" do
      expect(page).to have_content("No plants added yet!")
    end
    
    it "has a link to add a new plant" do
      expect(page).to have_link("Add Plant")
    end
  end
end
```

### 12.5 Factory Definitions

```ruby
# spec/factories/plants.rb
FactoryBot.define do
  factory :plant do
    sequence(:slug) { |n| "plant_#{n}" }
    species { "Monstera Deliciosa" }
    location { "Living Room" }
    preferred_moisture_min { 30 }
    preferred_moisture_max { 60 }
    care_notes { "Water when soil is dry" }
  end
end

# spec/factories/moisture_readings.rb
FactoryBot.define do
  factory :moisture_reading do
    association :plant
    moisture_level { rand(0..100) }
    recorded_at { Time.current }
  end
end
```

## 13. Implementation Roadmap

### 13.1 Phase 1: Core Application Setup

1. Initialize Rails 8.02 application with PostgreSQL
2. Configure asset pipeline with Propshaft
3. Set up TailwindCSS with Tokyo Night theme variables
4. Create database migrations and models
5. Implement basic API endpoint for receiving readings

### 13.2 Phase 2: User Interface Development

1. Create dashboard controller and view
2. Implement plant views (index, show, new, edit)
3. Design plant card component with small trend graph
4. Create moisture history visualization
5. Implement form for plant management

### 13.3 Phase 3: Real-Time Features

1. Set up Hotwire and Stimulus controllers
2. Implement real-time updates with Turbo Streams
3. Create trend and chart visualization components
4. Configure appropriate broadcast channels

### 13.4 Phase 4: Testing and Refinement

1. Write comprehensive test suite
2. Implement error handling
3. Create sample data generation tools
4. Performance testing with large datasets
5. UI/UX refinements

### 13.5 Phase 5: Production Preparation

1. Configure production environment
2. Set up deployment workflow
3. Documentation
4. Final testing and bug fixes

## 14. Security Considerations

Since this is a home project without authentication requirements, we've kept security minimal. However, for completeness, these are important considerations:

1. **API Rate Limiting**: Implement to prevent flooding the endpoint
2. **Input Validation**: Ensure all parameters are properly validated
3. **CSRF Protection**: Enabled by default in Rails for browser-based forms
4. **Secure Headers**: Configure appropriate security headers for the web interface
5. **Error Disclosure**: Ensure production errors don't leak sensitive information

## 15. Appendix: Environment Setup

### 15.1 Initial Project Setup

```bash
# Create a new Rails 8.02 application
rails new plant_monitor --database=postgresql --javascript=importmap --css=tailwind

# Navigate to the project directory
cd plant_monitor

# Generate models
rails generate model Plant slug:string species:string location:string preferred_moisture_min:integer preferred_moisture_max:integer care_notes:text
rails generate model MoistureReading plant:references moisture_level:integer recorded_at:datetime

# Run migrations
rails db:create db:migrate

# Set up RSpec
rails generate rspec:install

# Generate controllers
rails generate controller Dashboard index
rails generate controller Plants index show new edit
rails generate controller Api::Readings --skip-template-engine
```

### 15.2 Tailwind CSS Configuration

```javascript
// tailwind.config.js
module.exports = {
  content: [
    './app/views/**/*.{erb,html}',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js'
  ],
  theme: {
    extend: {
      colors: {
        // Colors will be accessed via CSS variables for theming
      }
    },
  },
  plugins: [],
}
```

### 15.3 Package Dependencies

```json
// package.json
{
  "dependencies": {
    "@hotwired/stimulus": "^3.2.2",
    "@hotwired/turbo-rails": "^8.0.0-beta.1",
    "chart.js": "^4.4.1",
    "chartjs-adapter-date-fns": "^3.0.0",
    "date-fns": "^2.30.0",
    "htmx.org": "^1.9.10"
  }
}
```

### 15.4 Importmap Configuration

```ruby
# config/importmap.rb
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin "chart.js", to: "https://ga.jspm.io/npm:chart.js@4.4.1/dist/chart.umd.js"
pin "date-fns", to: "https://ga.jspm.io/npm:date-fns@2.30.0/index.js"
pin "chartjs-adapter-date-fns", to: "https://ga.jspm.io/npm:chartjs-adapter-date-fns@3.0.0/dist/chartjs-adapter-date-fns.esm.js"
pin "htmx.org", to: "https://ga.jspm.io/npm:htmx.org@1.9.10/dist/htmx.min.js"
```