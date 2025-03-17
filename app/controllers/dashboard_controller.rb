class DashboardController < ApplicationController
  # Skip forgery protection for API endpoints
  skip_before_action :verify_authenticity_token, only: [:poll_updates]
  
  def index
    @plants = Plant.includes(:moisture_readings).order(:slug)
    @plants_grid = @plants.in_groups_of(3, false)

    if params[:view] == 'grid'
      @display_grid = true
    else
      @display_grid = false
    end
    
    respond_to do |format|
      format.html do
        # For HTMX refreshes of just the grid container
        if request.headers['HX-Request'] && @display_grid
          render partial: 'plants_grid_container', locals: { plants: @plants }
          return
        end
        
        # Regular HTML view
        render :index
      end
    end
  end
  
  # Endpoint for efficient polling that only returns changed plants
  def poll_updates
    begin
      # Get timestamp from the last poll or default to 30 seconds ago
      last_poll_time = begin
        Time.zone.parse(params[:last_updated]) 
      rescue
        30.seconds.ago
      end
      
      # Find plants that have been updated since the last poll
      @changed_plants = Plant.includes(:moisture_readings)
                           .where('plants.updated_at > ?', last_poll_time)
                           .order(:slug)
      
      Rails.logger.debug "Poll update request - Last poll time: #{last_poll_time}"
      Rails.logger.debug "Changed plants count: #{@changed_plants.count}"
      if @changed_plants.any?
        Rails.logger.debug "Changed plants: #{@changed_plants.map(&:slug).join(', ')}"
      end
      
      # The current poll time that will be sent back to client
      @current_poll_time = Time.current.to_s
      
      updates = {
        timestamp: @current_poll_time,
        has_changes: @changed_plants.any?,
        plants: []
      }
      
      # Only include plants that have changed
      @changed_plants.each do |plant|
        # Generate HTML for table row and card
        table_row = render_to_string(
          partial: 'plants/plant', 
          locals: { plant: plant, highlight: true },
          formats: [:html],
          layout: false
        )
        
        card_html = render_to_string(
          partial: 'plants/plant_card',
          locals: { plant: plant, highlight: true },
          formats: [:html],
          layout: false
        )
        
        # Add to updates
        updates[:plants] << {
          id: plant.id,
          table_html: table_row,
          card_html: card_html
        }
      end
      
      Rails.logger.debug "Response payload: has_changes=#{updates[:has_changes]}, plants_count=#{updates[:plants].size}"
      render json: updates
    
    rescue => e
      Rails.logger.error "Error in poll_updates: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      
      # Return a simple error response to help debugging
      render json: { error: e.message, timestamp: Time.current.to_s }, status: :internal_server_error
    end
  end
end
