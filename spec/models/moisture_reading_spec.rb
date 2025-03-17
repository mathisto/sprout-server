require 'rails_helper'

RSpec.describe MoistureReading, type: :model do
  describe "validations" do
    it { should validate_presence_of(:moisture_level) }
    it { should validate_presence_of(:recorded_at) }
    
    it { should validate_numericality_of(:moisture_level)
                .only_integer
                .is_greater_than_or_equal_to(0)
                .is_less_than_or_equal_to(100) }
  end
  
  describe "associations" do
    it { should belong_to(:plant) }
  end
  
  describe "factory" do
    it "creates a valid moisture reading" do
      reading = build(:moisture_reading)
      expect(reading).to be_valid
    end
    
    it "associates with a plant" do
      reading = create(:moisture_reading)
      expect(reading.plant).to be_present
    end
  end
end
