require 'rails_helper'

RSpec.describe "API::Readings", type: :request do
  describe "POST /api/readings" do
    context "with valid parameters" do
      let(:valid_params) do
        {
          id: 1,
          slug: "monstera",
          moisture: 75
        }
      end
      
      context "when the plant already exists" do
        before do
          create(:plant, id: 1, slug: "monstera")
        end
        
        it "creates a new moisture reading" do
          expect {
            post "/api/readings", params: valid_params
          }.to change(MoistureReading, :count).by(1)
        end
        
        it "returns a 201 Created status" do
          post "/api/readings", params: valid_params
          expect(response).to have_http_status(:created)
        end
        
        it "returns JSON with success message and reading details" do
          post "/api/readings", params: valid_params
          
          json_response = JSON.parse(response.body)
          expect(json_response["success"]).to be true
          expect(json_response["reading_id"]).to be_present
          expect(json_response["timestamp"]).to be_present
        end
      end
      
      context "when the plant doesn't exist" do
        it "creates a new plant" do
          expect {
            post "/api/readings", params: valid_params
          }.to change(Plant, :count).by(1)
        end
        
        it "creates a new moisture reading" do
          expect {
            post "/api/readings", params: valid_params
          }.to change(MoistureReading, :count).by(1)
        end
        
        it "returns a 201 Created status" do
          post "/api/readings", params: valid_params
          expect(response).to have_http_status(:created)
        end
      end
    end
    
    context "with invalid parameters" do
      context "when moisture level is out of range" do
        let(:invalid_params) do
          {
            id: 1,
            slug: "monstera",
            moisture: 150 # Out of range (0-100)
          }
        end
        
        it "doesn't create a moisture reading" do
          expect {
            post "/api/readings", params: invalid_params
          }.not_to change(MoistureReading, :count)
        end
        
        it "returns a 422 Unprocessable Entity status" do
          post "/api/readings", params: invalid_params
          expect(response).to have_http_status(:unprocessable_entity)
        end
        
        it "returns JSON with error message" do
          post "/api/readings", params: invalid_params
          
          json_response = JSON.parse(response.body)
          expect(json_response["success"]).to be false
          expect(json_response["errors"]).to include("Moisture level must be between 0 and 100")
        end
      end
      
      context "when required parameters are missing" do
        let(:missing_params) do
          {
            id: 1,
            # slug is missing
            moisture: 75
          }
        end
        
        it "doesn't create a moisture reading" do
          expect {
            post "/api/readings", params: missing_params
          }.not_to change(MoistureReading, :count)
        end
        
        it "returns a 400 Bad Request status" do
          post "/api/readings", params: missing_params
          expect(response).to have_http_status(:bad_request)
        end
        
        it "returns JSON with error message" do
          post "/api/readings", params: missing_params
          
          json_response = JSON.parse(response.body)
          expect(json_response["success"]).to be false
          expect(json_response["errors"]).to include("Missing required parameter: slug")
        end
      end
    end
  end
end 