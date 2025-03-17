class MoistureReading < ApplicationRecord
  belongs_to :plant, touch: true
  
  validates :moisture_level, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :recorded_at, presence: true
  
  scope :recent, -> { order(recorded_at: :desc) }
  
  after_create_commit :log_new_reading
  
  private
  
  def log_new_reading
    moisture_emoji = case moisture_level
      when 0..30 then "🏜️"   # Very dry
      when 31..45 then "🌱"  # Somewhat dry
      when 46..65 then "🌿"  # Optimal
      when 66..85 then "💧"  # Moist
      else "🌊"              # Very wet
    end

    status_emoji = case plant.moisture_status&.to_s
      when 'dry' then "⚠️"
      when 'optimal' then "✅"
      when 'wet' then "⚠️"
      else "❓"
    end

    Rails.logger.info "\n" + [
      "🪴 Plant Reading".ljust(15) + " | #{plant.name}",
      "📍 Location".ljust(15) + " | #{plant.location || 'Not specified'}",
      "#{moisture_emoji} Moisture".ljust(15) + " | #{moisture_level}%",
      "#{status_emoji} Status".ljust(15) + " | #{plant.moisture_status&.to_s&.titleize || 'Unknown'}",
      "⏰ Time".ljust(15) + " | #{recorded_at.strftime('%Y-%m-%d %H:%M:%S')}",
      "#{'-' * 50}"
    ].join("\n")
  end
end
