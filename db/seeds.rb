# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Basement Plants

# Golden Pothos
Plant.find_or_create_by!(slug: 'aurelia') do |plant|
  plant.species = 'Golden Pothos (Epipremnum aureum)'
  plant.location = 'Basement'
  plant.preferred_moisture_min = 30
  plant.preferred_moisture_max = 60
  plant.care_notes = 'Allow soil to dry slightly between waterings. Thrives in medium to bright indirect light but tolerates low light. Toxic to pets.'
end

Plant.find_or_create_by!(slug: 'aurelia-jr') do |plant|
  plant.species = 'Golden Pothos (Epipremnum aureum)'
  plant.location = 'Basement'
  plant.preferred_moisture_min = 30
  plant.preferred_moisture_max = 60
  plant.care_notes = 'Cutting from Aurelia. Allow soil to dry slightly between waterings. Thrives in medium to bright indirect light but tolerates low light.'
end

Plant.find_or_create_by!(slug: 'aurelia-sprout') do |plant|
  plant.species = 'Golden Pothos (Epipremnum aureum)'
  plant.location = 'Basement'
  plant.preferred_moisture_min = 30
  plant.preferred_moisture_max = 60
  plant.care_notes = 'Cutting from Aurelia. Allow soil to dry slightly between waterings. Thrives in medium to bright indirect light but tolerates low light.'
end

# Spider Plants
Plant.find_or_create_by!(slug: 'jade') do |plant|
  plant.species = 'Green Spider Plant (Chlorophytum comosum)'
  plant.location = 'Basement'
  plant.preferred_moisture_min = 30
  plant.preferred_moisture_max = 50
  plant.care_notes = 'Keep soil lightly moist but not soggy. Tolerates neglect. Bright indirect light is best. Sensitive to fluoride and salts in water.'
end

Plant.find_or_create_by!(slug: 'leilani') do |plant|
  plant.species = 'Hawaiian Spider Plant (Chlorophytum comosum "Hawaiin")'
  plant.location = 'Basement'
  plant.preferred_moisture_min = 30
  plant.preferred_moisture_max = 50
  plant.care_notes = 'Keep soil lightly moist. Variegated varieties like Hawaiian need more light than solid green varieties. Allow to dry slightly between waterings.'
end

Plant.find_or_create_by!(slug: 'marina') do |plant|
  plant.species = 'Ocean Spider Plant (Chlorophytum comosum "Ocean")'
  plant.location = 'Basement'
  plant.preferred_moisture_min = 30
  plant.preferred_moisture_max = 50
  plant.care_notes = 'Keep soil lightly moist. Variegated variety with blue-green tones. Bright indirect light is best to maintain coloration.'
end

Plant.find_or_create_by!(slug: 'curly-sue') do |plant|
  plant.species = 'Curly Bonnie Spider Plant (Chlorophytum comosum "Bonnie")'
  plant.location = 'Basement'
  plant.preferred_moisture_min = 30
  plant.preferred_moisture_max = 50
  plant.care_notes = 'Distinctive curly leaves. Keep soil lightly moist. Bright indirect light is best. Water when top inch of soil is dry.'
end

# Wandering Jew
Plant.find_or_create_by!(slug: 'violet-voyager') do |plant|
  plant.species = 'Wandering Jew (Tradescantia zebrina)'
  plant.location = 'Basement'
  plant.preferred_moisture_min = 30
  plant.preferred_moisture_max = 60
  plant.care_notes = 'Keep soil consistently moist but not waterlogged. Bright, indirect light for best color. Pinch back stems to encourage bushier growth.'
end

# Money Tree
Plant.find_or_create_by!(slug: 'fortune') do |plant|
  plant.species = 'Money Tree (Pachira aquatica)'
  plant.location = 'Basement'
  plant.preferred_moisture_min = 30
  plant.preferred_moisture_max = 60
  plant.care_notes = 'Allow top 2-4 inches of soil to dry out between waterings. Bright indirect light is best. Sensitive to overwatering and cold drafts.'
end
