require 'rails_helper'

RSpec.describe "Dashboard routing", type: :routing do
  describe "root path" do
    it "routes to dashboard#index" do
      expect(get: "/").to route_to("dashboard#index")
    end
  end
end 