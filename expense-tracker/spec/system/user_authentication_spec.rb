# frozen_string_literal: true

require "rails_helper"

RSpec.describe "User Authentication", type: :system do
  before do
    driven_by(:selenium_headless)
  end

  describe "User Registration" do
    it "allows a new user to sign up with valid credentials" do
      visit new_user_registration_path

      fill_in "Full name", with: "John Doe"
      fill_in "Email", with: "john@example.com"
      fill_in "Password", with: "Password123!"
      fill_in "Password confirmation", with: "Password123!"

      click_button "Sign up"

      expect(page).to have_content("Welcome")
      expect(page).to have_content("John Doe")
      expect(page).to have_link("Logout")
    end

    it "shows validation errors with invalid email" do
      visit new_user_registration_path

      fill_in "Email", with: "invalid_email"
      fill_in "Password", with: "Password123!"
      fill_in "Password confirmation", with: "Password123!"

      click_button "Sign up"

      expect(page).to have_content("Email is invalid")
      expect(page).not_to have_link("Logout")
    end

    it "shows validation errors with weak password" do
      visit new_user_registration_path

      fill_in "Email", with: "john@example.com"
      fill_in "Password", with: "weak"
      fill_in "Password confirmation", with: "weak"

      click_button "Sign up"

      expect(page).to have_content(/password/i)
      expect(page).to have_content(/uppercase|lowercase|digit|special/i)
      expect(page).not_to have_link("Logout")
    end

    it "shows validation errors with mismatched passwords" do
      visit new_user_registration_path

      fill_in "Email", with: "john@example.com"
      fill_in "Password", with: "Password123!"
      fill_in "Password confirmation", with: "DifferentPassword123!"

      click_button "Sign up"

      expect(page).to have_content("Password confirmation doesn't match")
      expect(page).not_to have_link("Logout")
    end

    it "prevents duplicate email registration" do
      create(:user, email: "existing@example.com", password: "Password123!")

      visit new_user_registration_path

      fill_in "Email", with: "existing@example.com"
      fill_in "Password", with: "Password123!"
      fill_in "Password confirmation", with: "Password123!"

      click_button "Sign up"

      expect(page).to have_content("Email has already been taken")
      expect(page).not_to have_link("Logout")
    end
  end

  describe "User Sign In" do
    let!(:user) { create(:user, email: "john@example.com", password: "Password123!", full_name: "John Doe") }

    it "allows existing user to sign in with valid credentials" do
      visit new_user_session_path

      fill_in "Email", with: "john@example.com"
      fill_in "Password", with: "Password123!"

      click_button "Log in"

      expect(page).to have_content("Signed in successfully")
      expect(page).to have_content("John Doe")
      expect(page).to have_link("Logout")
    end

    it "rejects invalid credentials" do
      visit new_user_session_path

      fill_in "Email", with: "john@example.com"
      fill_in "Password", with: "WrongPassword123!"

      click_button "Log in"

      expect(page).to have_content("Invalid Email or password")
      expect(page).not_to have_link("Logout")
      expect(page).to have_field("Email")
    end

    it "rejects non-existent user" do
      visit new_user_session_path

      fill_in "Email", with: "nonexistent@example.com"
      fill_in "Password", with: "Password123!"

      click_button "Log in"

      expect(page).to have_content("Invalid Email or password")
      expect(page).not_to have_link("Logout")
    end

    it "shows the remember me option" do
      visit new_user_session_path

      expect(page).to have_field("Remember me")
    end

    it "has a link to password reset" do
      visit new_user_session_path

      expect(page).to have_link("Forgot your password?")
    end

    it "has a link to sign up" do
      visit new_user_session_path

      expect(page).to have_link("Sign up")
    end
  end

  describe "User Sign Out" do
    let!(:user) { create(:user, email: "john@example.com", password: "Password123!", full_name: "John Doe") }

    before do
      visit new_user_session_path
      fill_in "Email", with: "john@example.com"
      fill_in "Password", with: "Password123!"
      click_button "Log in"
    end

    it "allows signed-in user to sign out" do
      click_button "Logout"

      expect(page).to have_content("Signed out successfully")
      expect(page).not_to have_link("Logout")
      expect(page).to have_link("Log in", href: new_user_session_path)
    end

    it "redirects to login page after sign out" do
      click_button "Logout"

      expect(current_path).to eq(root_path)
      visit dashboard_path
      expect(current_path).to eq(new_user_session_path)
    end
  end

  describe "Password Reset" do
    let!(:user) { create(:user, email: "john@example.com", password: "Password123!") }

    it "allows user to request password reset" do
      visit new_user_session_path
      click_link "Forgot your password?"

      expect(current_path).to eq(new_user_password_path)

      fill_in "Email", with: "john@example.com"
      click_button "Send me reset password instructions"

      expect(page).to have_content(/email.*instructions/i)
      expect(ActionMailer::Base.deliveries.last.to).to include("john@example.com")
    end

    it "allows user to reset password with valid token" do
      visit new_user_password_path
      fill_in "Email", with: "john@example.com"
      click_button "Send me reset password instructions"

      # Get the reset token from the email
      email = ActionMailer::Base.deliveries.last
      reset_url = email.body.match(%r{href="([^"]*password/edit[^"]*)"})[1]

      visit reset_url

      fill_in "New password", with: "NewPassword123!"
      fill_in "Confirm new password", with: "NewPassword123!"
      click_button "Change my password"

      expect(page).to have_content("password.*changed/i")
      expect(page).to have_link("Logout")

      # Verify can sign in with new password
      click_button "Logout"
      visit new_user_session_path
      fill_in "Email", with: "john@example.com"
      fill_in "Password", with: "NewPassword123!"
      click_button "Log in"

      expect(page).to have_content("Signed in successfully")
    end

    it "shows error with weak password during reset" do
      user.send_reset_password_instructions
      token = user.reload.reset_password_token

      visit edit_user_password_path(reset_password_token: token)

      fill_in "New password", with: "weak"
      fill_in "Confirm new password", with: "weak"
      click_button "Change my password"

      expect(page).to have_content(/password/i)
      expect(page).not_to have_link("Logout")
    end

    it "handles non-existent email gracefully" do
      visit new_user_password_path

      fill_in "Email", with: "nonexistent@example.com"
      click_button "Send me reset password instructions"

      # Should still show success to prevent email enumeration
      expect(page).to have_content(/email.*instructions/i)
      expect(ActionMailer::Base.deliveries.count).to eq(0)
    end
  end

  describe "Protected Pages" do
    it "redirects to login when accessing protected pages while signed out" do
      visit dashboard_path

      expect(current_path).to eq(new_user_session_path)
      expect(page).to have_content(/sign in|log in/i)
    end

    it "allows access to protected pages when signed in" do
      user = create(:user, password: "Password123!")

      visit new_user_session_path
      fill_in "Email", with: user.email
      fill_in "Password", with: "Password123!"
      click_button "Log in"

      visit dashboard_path
      expect(current_path).to eq(dashboard_path)
    end
  end

  describe "Session Timeout" do
    let!(:user) { create(:user, email: "john@example.com", password: "Password123!") }

    it "expires session after timeout period", :skip do
      # NOTE: This test requires time travel which is complex in system tests
      # Consider testing timeout in request specs instead
      skip "Session timeout better tested in request specs"
    end
  end
end
