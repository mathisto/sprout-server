require 'rails_helper'

RSpec.describe "Dashboard", type: :system do
  before do
    driven_by(:rack_test)
  end

  context "with no plants" do
    it "shows empty state message" do
      visit root_path
      
      expect(page).to have_content("No plants registered yet")
      expect(page).to have_link("Add a plant", href: new_plant_path)
    end
  end

  context "with existing plants" do
    before do
      @plant1 = create(:plant, slug: "monstera", species: "Monstera deliciosa")
      @plant2 = create(:plant, slug: "snake-plant", species: "Dracaena trifasciata")
      
      # Add a moisture reading to one plant
      create(:moisture_reading, plant: @plant1, moisture_level: 65)
    end

    it "displays plants with their moisture status" do
      visit root_path
      
      expect(page).to have_content("Monstera deliciosa")
      expect(page).to have_content("Dracaena trifasciata")
      
      # It should show the current moisture for the plant with readings
      expect(page).to have_content("65%")
      
      # It should show a no readings message for the plant without readings
      within("[data-plant-slug='snake-plant']") do
        expect(page).to have_content("No readings")
      end
    end

    it "allows navigation to individual plant details" do
      visit root_path
      
      click_link "Monstera deliciosa"
      expect(page).to have_current_path(plant_path(@plant1))
    end
  end
end 