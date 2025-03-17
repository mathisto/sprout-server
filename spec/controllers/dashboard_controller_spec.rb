require 'rails_helper'

RSpec.describe DashboardController, type: :controller do
  describe "GET #index" do
    it "assigns @plants with all plants ordered by slug" do
      plant1 = create(:plant, slug: 'plant-b')
      plant2 = create(:plant, slug: 'plant-a')
      
      get :index
      expect(assigns(:plants)).to eq([plant2, plant1])
    end

    it "renders the index template" do
      get :index
      expect(response).to render_template("index")
    end
  end
end 