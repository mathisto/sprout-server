FactoryBot.define do
  factory :plant do
    sequence(:slug) { |n| "plant-#{n}" }
    species { "Monstera Deliciosa" }
    location { "Living Room" }
    preferred_moisture_min { 30 }
    preferred_moisture_max { 70 }
    care_notes { "Water when soil is dry to touch" }
  end
end
