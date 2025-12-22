# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Password Reset", type: :request do
  let(:user) { create(:user, password: "Password123!", password_confirmation: "Password123!") }

  describe "GET /users/password/new (Password Reset Form)" do
    it "renders the password reset form" do
      get new_user_password_path
      expect(response).to have_http_status(:success)
      expect(response.body).to match(/forgot.*password/i)
    end
  end

  describe "POST /users/password (Send Reset Instructions)" do
    context "with valid email" do
      it "sends password reset instructions" do
        expect do
          post user_password_path, params: {
            user: { email: user.email }
          }
        end.to change { ActionMailer::Base.deliveries.count }.by(1)
      end

      it "redirects to login page" do
        post user_password_path, params: {
          user: { email: user.email }
        }
        expect(response).to redirect_to(new_user_session_path)
      end

      it "shows success message" do
        post user_password_path, params: {
          user: { email: user.email }
        }
        follow_redirect!
        expect(response.body).to match(/email.*instructions/i)
      end

      it "generates a reset token" do
        post user_password_path, params: {
          user: { email: user.email }
        }
        user.reload
        expect(user.reset_password_token).to be_present
      end
    end

    context "with invalid email" do
      it "does not send email" do
        expect do
          post user_password_path, params: {
            user: { email: "nonexistent@example.com" }
          }
        end.not_to(change { ActionMailer::Base.deliveries.count })
      end

      it "still shows success message (security)" do
        post user_password_path, params: {
          user: { email: "nonexistent@example.com" }
        }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET /users/password/edit (Password Reset Edit Form)" do
    before do
      user.send_reset_password_instructions
      user.reload
    end

    it "renders the password reset edit form with valid token" do
      get edit_user_password_path(reset_password_token: user.reset_password_token)
      expect(response).to have_http_status(:success)
      expect(response.body).to match(/change.*password/i)
    end

    it "redirects with invalid token" do
      get edit_user_password_path(reset_password_token: "invalid_token")
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "PUT /users/password (Reset Password)" do
    before do
      user.send_reset_password_instructions
      user.reload
    end

    context "with valid token and password" do
      let(:reset_params) do
        {
          user: {
            reset_password_token: user.reset_password_token,
            password: "NewPassword123!",
            password_confirmation: "NewPassword123!"
          }
        }
      end

      it "updates the password" do
        put user_password_path, params: reset_params
        user.reload
        expect(user.valid_password?("NewPassword123!")).to be true
      end

      it "signs in the user" do
        put user_password_path, params: reset_params
        expect(controller.current_user).to eq(user)
      end

      it "redirects to root path" do
        put user_password_path, params: reset_params
        expect(response).to redirect_to(root_path)
      end

      it "clears the reset token" do
        put user_password_path, params: reset_params
        user.reload
        expect(user.reset_password_token).to be_nil
      end
    end

    context "with invalid token" do
      it "does not update the password" do
        original_encrypted_password = user.encrypted_password
        put user_password_path, params: {
          user: {
            reset_password_token: "invalid_token",
            password: "NewPassword123!",
            password_confirmation: "NewPassword123!"
          }
        }
        user.reload
        expect(user.encrypted_password).to eq(original_encrypted_password)
      end
    end

    context "with weak password" do
      let(:weak_password_params) do
        {
          user: {
            reset_password_token: user.reset_password_token,
            password: "weak",
            password_confirmation: "weak"
          }
        }
      end

      it "does not update the password" do
        original_encrypted_password = user.encrypted_password
        put user_password_path, params: weak_password_params
        user.reload
        expect(user.encrypted_password).to eq(original_encrypted_password)
      end

      it "shows validation errors" do
        put user_password_path, params: weak_password_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to match(/password/i)
      end
    end

    context "with mismatched passwords" do
      let(:mismatched_params) do
        {
          user: {
            reset_password_token: user.reset_password_token,
            password: "NewPassword123!",
            password_confirmation: "DifferentPassword123!"
          }
        }
      end

      it "does not update the password" do
        original_encrypted_password = user.encrypted_password
        put user_password_path, params: mismatched_params
        user.reload
        expect(user.encrypted_password).to eq(original_encrypted_password)
      end
    end

    context "with expired token" do
      it "does not reset password" do
        user.send_reset_password_instructions
        user.reload

        travel_to 7.hours.from_now do
          put user_password_path, params: {
            user: {
              reset_password_token: user.reset_password_token,
              password: "NewPassword123!",
              password_confirmation: "NewPassword123!"
            }
          }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
end
