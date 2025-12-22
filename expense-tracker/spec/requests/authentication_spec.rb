# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Authentication", type: :request do
  let(:user) { create(:user, password: "Password123!", password_confirmation: "Password123!") }

  describe "POST /users (Sign Up)" do
    context "with valid parameters" do
      let(:valid_attributes) do
        {
          user: {
            email: "newuser@example.com",
            full_name: "New User",
            password: "Password123!",
            password_confirmation: "Password123!"
          }
        }
      end

      it "creates a new user" do
        expect do
          post user_registration_path, params: valid_attributes
        end.to change(User, :count).by(1)
      end

      it "signs in the new user" do
        post user_registration_path, params: valid_attributes
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include("New User")
      end

      it "redirects to the root path" do
        post user_registration_path, params: valid_attributes
        expect(response).to redirect_to(root_path)
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) do
        {
          user: {
            email: "invalid_email",
            full_name: "Test User",
            password: "weak",
            password_confirmation: "weak"
          }
        }
      end

      it "does not create a new user" do
        expect do
          post user_registration_path, params: invalid_attributes
        end.not_to change(User, :count)
      end

      it "renders the signup form again" do
        post user_registration_path, params: invalid_attributes
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "with weak password" do
      let(:weak_password_attributes) do
        {
          user: {
            email: "newuser@example.com",
            full_name: "Test User",
            password: "password",
            password_confirmation: "password"
          }
        }
      end

      it "does not create a new user" do
        expect do
          post user_registration_path, params: weak_password_attributes
        end.not_to change(User, :count)
      end

      it "shows password complexity error" do
        post user_registration_path, params: weak_password_attributes
        expect(response.body).to match(/password/i)
      end
    end
  end

  describe "POST /users/sign_in (Sign In)" do
    context "with valid credentials" do
      it "signs in the user" do
        post user_session_path, params: {
          user: {
            email: user.email,
            password: "Password123!"
          }
        }
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include(user.full_name)
      end

      it "redirects to the root path" do
        post user_session_path, params: {
          user: {
            email: user.email,
            password: "Password123!"
          }
        }
        expect(response).to redirect_to(root_path)
      end
    end

    context "with invalid credentials" do
      it "does not sign in the user" do
        post user_session_path, params: {
          user: {
            email: user.email,
            password: "WrongPassword123!"
          }
        }
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "renders the login form again" do
        post user_session_path, params: {
          user: {
            email: user.email,
            password: "WrongPassword123!"
          }
        }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "with non-existent user" do
      it "does not sign in" do
        post user_session_path, params: {
          user: {
            email: "nonexistent@example.com",
            password: "Password123!"
          }
        }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /users/sign_out (Sign Out)" do
    before { sign_in user }

    it "signs out the user" do
      delete destroy_user_session_path
      expect(response).to redirect_to(root_path)
    end

    it "redirects to the root path" do
      delete destroy_user_session_path
      expect(response).to redirect_to(root_path)
    end
  end

  describe "Session timeout" do
    before { sign_in user }

    it "expires session after timeout period" do
      # Simulate session timeout by setting last_request_at to past
      travel 31.minutes do
        get root_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    it "does not expire session within timeout period" do
      travel 29.minutes do
        get root_path
        expect(response).to have_http_status(:success)
      end
    end
  end
end
