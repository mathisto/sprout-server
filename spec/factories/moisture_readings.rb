FactoryBot.define do
  factory :moisture_reading do
    association :plant
    moisture_level { rand(0..100) }
    recorded_at { Time.current }
  end
end
