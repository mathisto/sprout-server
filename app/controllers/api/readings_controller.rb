module Api
  class ReadingsController < ApplicationController
    skip_before_action :verify_authenticity_token
    
    def create
      # Validate required parameters
      unless params[:slug].present? && params[:moisture].present?
        missing_params = []
        missing_params << "slug" unless params[:slug].present?
        missing_params << "moisture" unless params[:moisture].present?
        
        errors = missing_params.map { |param| "Missing required parameter: #{param}" }
        Rails.logger.warn("API Reading Error: #{errors.join(', ')}")
        
        return render json: {
          success: false,
          errors: errors
        }, status: :bad_request
      end
      
      # Validate moisture range
      moisture = params[:moisture].to_i
      unless (0..100).cover?(moisture)
        Rails.logger.warn("API Reading Error: Moisture level #{moisture} is out of range 0-100")
        return render json: {
          success: false,
          errors: ["Moisture level must be between 0 and 100"]
        }, status: :unprocessable_entity
      end
      
      # Find or create plant
      plant = Plant.find_or_create_by(slug: params[:slug]) do |p|
        # Set properties if provided
        p.name = params[:name] if params[:name].present?
        p.species = params[:species] if params[:species].present?
        p.location = params[:location] if params[:location].present?
        p.id = params[:id] if params[:id].present?
      end
      
      # Update plant if attributes are provided
      plant_updated = false
      if plant.persisted?
        if params[:name].present? && plant.name != params[:name]
          plant.name = params[:name]
          plant_updated = true
        end
        
        if params[:species].present? && plant.species != params[:species]
          plant.species = params[:species]
          plant_updated = true
        end
        
        if params[:location].present? && plant.location != params[:location]
          plant.location = params[:location]
          plant_updated = true
        end
        
        plant.save if plant_updated
      end
      
      # Create moisture reading
      reading = plant.moisture_readings.create!(
        moisture_level: moisture,
        recorded_at: Time.current
      )
      
      # Log successful reading
      Rails.logger.info("Plant Reading Received: Plant '#{plant.slug}' with moisture level #{moisture}")
      
      # Return success response
      render json: {
        success: true,
        reading_id: reading.id,
        timestamp: reading.recorded_at.iso8601
      }, status: :created
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error("API Reading Error: #{e.message}")
      render json: {
        success: false,
        errors: [e.message]
      }, status: :unprocessable_entity
    rescue => e
      Rails.logger.error("API Reading Error: Unexpected error - #{e.message}")
      render json: {
        success: false,
        errors: ["Internal server error"]
      }, status: :internal_server_error
    end
  end
end 