# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Debug Registration", type: :request do
  it "shows what happens when we try to register" do
    params = {
      user: {
        email: "test@example.com",
        full_name: "Test User",
        password: "Password123!",
        password_confirmation: "Password123!"
      }
    }
    
    post user_registration_path, params: params
    
    puts "\n=== DEBUG INFO ==="
    puts "Status: #{response.status}"
    puts "Content-Type: #{response.content_type}"
    puts "Location: #{response.location}"
    puts "Rails Env: #{Rails.env}"
    puts "Hosts config: #{Rails.application.config.hosts.inspect}"
    puts "Body (1000 chars): #{response.body[0..1000]}"
    puts "User count: #{User.count}"
    puts "Last user: #{User.last&.email}"
    puts "==================\n"
    
    expect(true).to be true # Just to pass
  end
end
