require 'rails_helper'

RSpec.describe "Smoke test" do
  it "passes if Rails is properly configured" do
    expect(Rails.env).to eq('test')
    expect(Rails.application.class.to_s).to eq('SproutServer::Application')
  end
end 