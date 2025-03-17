require 'rails_helper'

RSpec.describe Plant, type: :model do
  describe "validations" do
    it { should validate_presence_of(:slug) }
    it { should validate_uniqueness_of(:slug) }
    
    it { should validate_numericality_of(:preferred_moisture_min)
                .only_integer
                .is_greater_than_or_equal_to(0)
                .is_less_than_or_equal_to(100)
                .allow_nil }
                
    it { should validate_numericality_of(:preferred_moisture_max)
                .only_integer
                .is_greater_than_or_equal_to(0)
                .is_less_than_or_equal_to(100)
                .allow_nil }
    
    context "when preferred moisture range is set" do
      let(:plant) { build(:plant, preferred_moisture_min: 60, preferred_moisture_max: 50) }
      
      it "validates that preferred_moisture_min is less than preferred_moisture_max" do
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
    
    context "when no readings exist" do
      it "returns nil" do
        expect(plant.current_moisture).to be_nil
      end
    end
    
    context "when readings exist" do
      before do
        create(:moisture_reading, plant: plant, moisture_level: 30, recorded_at: 2.days.ago)
        create(:moisture_reading, plant: plant, moisture_level: 40, recorded_at: 1.day.ago)
        create(:moisture_reading, plant: plant, moisture_level: 50, recorded_at: Time.current)
      end
      
      it "returns the moisture level from the most recent reading" do
        expect(plant.current_moisture).to eq(50)
      end
    end
  end
  
  describe "#moisture_status" do
    let(:plant) { create(:plant, preferred_moisture_min: 40, preferred_moisture_max: 70) }
    
    context "when no readings exist" do
      it "returns :unknown" do
        expect(plant.moisture_status).to eq(:unknown)
      end
    end
    
    context "when no preferred range is set" do
      let(:plant) { create(:plant, preferred_moisture_min: nil, preferred_moisture_max: nil) }
      
      before do
        create(:moisture_reading, plant: plant, moisture_level: 50, recorded_at: Time.current)
      end
      
      it "returns :unknown" do
        expect(plant.moisture_status).to eq(:unknown)
      end
    end
    
    context "when moisture is below preferred range" do
      before do
        create(:moisture_reading, plant: plant, moisture_level: 30, recorded_at: Time.current)
      end
      
      it "returns :too_dry" do
        expect(plant.moisture_status).to eq(:too_dry)
      end
    end
    
    context "when moisture is within preferred range" do
      before do
        create(:moisture_reading, plant: plant, moisture_level: 60, recorded_at: Time.current)
      end
      
      it "returns :ideal" do
        expect(plant.moisture_status).to eq(:ideal)
      end
    end
    
    context "when moisture is above preferred range" do
      before do
        create(:moisture_reading, plant: plant, moisture_level: 80, recorded_at: Time.current)
      end
      
      it "returns :too_wet" do
        expect(plant.moisture_status).to eq(:too_wet)
      end
    end
  end
  
  describe "#recent_readings" do
    let(:plant) { create(:plant) }
    
    before do
      # Create 30 readings with different timestamps
      30.times do |i|
        create(:moisture_reading, 
               plant: plant, 
               moisture_level: i + 30, 
               recorded_at: (30 - i).hours.ago)
      end
    end
    
    it "returns the most recent readings in chronological order" do
      readings = plant.recent_readings(5)
      
      expect(readings.size).to eq(5)
      expect(readings.first.moisture_level).to eq(55)
      expect(readings.last.moisture_level).to eq(59)
    end
    
    it "defaults to 24 readings" do
      expect(plant.recent_readings.size).to eq(24)
    end
  end
  
  describe "#readings_for_chart" do
    let(:plant) { create(:plant) }
    
    before do
      # Create readings across different days
      10.times do |i|
        create(:moisture_reading, 
               plant: plant, 
               moisture_level: i + 40, 
               recorded_at: i.days.ago)
      end
    end
    
    it "returns readings from the specified number of days" do
      readings = plant.readings_for_chart(days: 5)
      
      expect(readings.size).to eq(5) # Today + 4 previous days
      expect(readings.first.recorded_at.to_date).to eq(4.days.ago.to_date)
      expect(readings.last.recorded_at.to_date).to eq(Time.current.to_date)
    end
    
    it "defaults to 7 days" do
      readings = plant.readings_for_chart
      
      expect(readings.size).to eq(7) # Today + 6 previous days
    end
  end
end
