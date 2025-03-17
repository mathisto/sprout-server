class Plant < ApplicationRecord
  has_many :moisture_readings, dependent: :destroy
  
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9\-_]+\z/, message: "only allows lowercase letters, numbers, hyphens and underscores" }
  
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
  
  validate :preferred_moisture_range_order
  
  # Use slug instead of id in URLs
  def to_param
    slug
  end
  
  # Use slug as name for display purposes
  def name
    slug.titleize
  end
  
  def current_moisture
    @current_moisture ||= recent_readings(1).first&.moisture_level
  end
  
  def last_reading_time
    @last_reading_time ||= recent_readings(1).first&.recorded_at
  end
  
  def moisture_status
    @moisture_status ||= moisture_status_for(current_moisture) if current_moisture
  end
  
  def moisture_status_for(moisture_level)
    return nil unless moisture_level
    
    if preferred_moisture_min.present? && preferred_moisture_max.present?
      if moisture_level < preferred_moisture_min
        'dry'
      elsif moisture_level > preferred_moisture_max
        'wet'
      else
        'optimal'
      end
    else
      # Default ranges if not specified
      if moisture_level < 30
        'dry'
      elsif moisture_level > 70
        'wet'
      else
        'optimal'
      end
    end
  end
  
  def recent_readings(limit = 10)
    @recent_readings ||= {}
    @recent_readings[limit] ||= moisture_readings.order(recorded_at: :desc).limit(limit).to_a
  end
  
  def readings_for_chart(days: 7)
    @readings_for_chart ||= {}
    @readings_for_chart[days] ||= moisture_readings
      .where('recorded_at >= ?', days.days.ago)
      .order(recorded_at: :asc)
      .to_a
  end
  
  # Get trend data for the small chart on plant cards
  def trend_data(days: 7, limit: 20)
    @trend_data ||= {}
    @trend_data["#{days}-#{limit}"] ||= begin
      readings = readings_for_chart(days: days)
               
      # If we have more readings than the limit, sample them to get a representative trend
      if readings.length > limit && readings.length > 0
        sample_interval = readings.length / limit
        readings = readings.each_slice(sample_interval).map(&:last).take(limit)
      end
      
      readings.map(&:moisture_level)
    end
  end
  
  # Calculate the last time period that provides enough readings for a trend
  def trend_period
    @trend_period ||= begin
      # Try different periods to find one with enough readings
      [7, 14, 30, 60, 90].each do |days|
        readings = moisture_readings.where('recorded_at >= ?', days.days.ago)
        return days if readings.count >= 5
      end
      
      # Default to 7 days if no period has enough readings
      7
    end
  end
  
  private
  
  def preferred_moisture_range_order
    if preferred_moisture_min.present? && preferred_moisture_max.present? && preferred_moisture_min > preferred_moisture_max
      errors.add(:preferred_moisture_min, "must be less than or equal to maximum moisture")
    end
  end
end
