namespace :sprout do
  desc "Clear all existing moisture readings"
  task clear_moisture_readings: :environment do
    puts "\r\n🧹 Clearing all moisture readings..."
    count = MoistureReading.delete_all
    puts "✨ Cleared #{count} moisture readings\n"
  end

  desc "Generate cyclical moisture readings from random plant (excluding Aurelia) via API every 5 seconds until stopped"
  task generate_moisture_readings: :environment do
    require 'io/console'
    require 'net/http'
    require 'uri'
    require 'json'

    puts "\r\n🌱 Starting Sprout Moisture Reading Generator..."
    puts "📱 Press any key to stop"
    puts "ℹ️  Excluding 'aurelia' from random selection (reserved for real sensor)"
    puts "-" * 60

    # Flag to control the loop
    running = true

    # Thread to listen for key press
    listener = Thread.new do
      STDIN.getch
      running = false
      puts "\r\n🛑 Stopping generator..."
    end

    # Get base URL for API calls
    host = ENV['API_HOST'] || 'localhost'
    port = ENV['API_PORT'] || '3000'
    base_url = "http://#{host}:#{port}/api/readings"

    # Store the direction and current moisture level for each plant
    plant_states = {}

    # Main loop to generate readings
    while running
      begin
        # Get a random plant, excluding Aurelia
        plant = Plant.where.not(slug: 'aurelia').order("RANDOM()").first
        
        if plant
          # Initialize plant state if not exists
          plant_states[plant.id] ||= {
            current: plant.preferred_moisture_min || 30,
            increasing: true
          }

          state = plant_states[plant.id]
          min_moisture = plant.preferred_moisture_min || 30
          max_moisture = plant.preferred_moisture_max || 60
          
          # Update moisture level based on direction
          if state[:increasing]
            state[:current] += 1
            if state[:current] >= max_moisture
              state[:increasing] = false
              state[:current] = max_moisture
            end
          else
            state[:current] -= 1
            if state[:current] <= min_moisture
              state[:increasing] = true
              state[:current] = min_moisture
            end
          end
          
          # Prepare the API request
          uri = URI.parse(base_url)
          http = Net::HTTP.new(uri.host, uri.port)
          request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
          
          # Create the payload
          payload = {
            slug: plant.slug,
            moisture: state[:current]
          }
          
          # Set the request body
          request.body = payload.to_json
          
          # Send the request to our own API
          start_time = Time.now
          response = http.request(request)
          duration = Time.now - start_time
          
          # Log the response with a more appealing format
          if response.code == '201'
            result = JSON.parse(response.body)
            
            # Determine emojis based on moisture level
            moisture_emoji = case state[:current]
              when 0..30 then "🏜️"   # Very dry
              when 31..45 then "🌱"  # Somewhat dry
              when 46..65 then "🌿"  # Optimal
              when 66..85 then "💧"  # Moist
              else "🌊"              # Very wet
            end

            direction_arrow = state[:increasing] ? "↗️" : "↘️"
            print "\r\n🪴 #{plant.name.ljust(15)} #{moisture_emoji} #{state[:current]}% #{direction_arrow} [#{response.code}] (#{duration.round(3)}s)"
          else
            print "\r\n❌ API Error: #{response.code} - #{response.body}"
          end
          
          # Wait for 5 seconds before next reading unless stopping
          sleep 5 unless !running
        else
          puts "\r\n❌ No eligible plants found in the database (excluding Aurelia). Please add some plants first."
          running = false
        end
      rescue => e
        print "\r\n❌ Error: #{e.message}"
        sleep 5 unless !running
      end
    end

    # Wait for the listener thread to complete
    listener.join
    puts "\r\n✨ Generator stopped successfully.\n"
  end
end 