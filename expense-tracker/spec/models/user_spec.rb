# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject { build(:user) }

    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should allow_value('user@example.com').for(:email) }
    it { should_not allow_value('invalid_email').for(:email) }

    describe 'password complexity' do
      it 'requires at least one uppercase letter' do
        user = build(:user, password: 'password123!', password_confirmation: 'password123!')
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include(match(/must include at least one uppercase letter/i))
      end

      it 'requires at least one lowercase letter' do
        user = build(:user, password: 'PASSWORD123!', password_confirmation: 'PASSWORD123!')
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include(match(/must include at least one lowercase letter/i))
      end

      it 'requires at least one digit' do
        user = build(:user, password: 'Password!', password_confirmation: 'Password!')
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include(match(/must include at least one digit/i))
      end

      it 'requires at least one special character' do
        user = build(:user, password: 'Password123', password_confirmation: 'Password123')
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include(match(/must include at least one special character/i))
      end

      it 'accepts a valid complex password' do
        user = build(:user, password: 'Password123!', password_confirmation: 'Password123!')
        expect(user).to be_valid
      end
    end
  end

  describe 'associations' do
    it { should have_many(:transactions).dependent(:destroy) }
    it { should have_many(:categories).dependent(:destroy) }
  end

  describe 'devise modules' do
    it 'includes database_authenticatable' do
      expect(User.devise_modules).to include(:database_authenticatable)
    end

    it 'includes registerable' do
      expect(User.devise_modules).to include(:registerable)
    end

    it 'includes recoverable' do
      expect(User.devise_modules).to include(:recoverable)
    end

    it 'includes rememberable' do
      expect(User.devise_modules).to include(:rememberable)
    end

    it 'includes validatable' do
      expect(User.devise_modules).to include(:validatable)
    end

    it 'includes timeoutable' do
      expect(User.devise_modules).to include(:timeoutable)
    end
  end

  describe 'full_name' do
    it 'can store a full name' do
      user = create(:user, full_name: 'John Doe')
      expect(user.full_name).to eq('John Doe')
    end

    it 'allows nil full_name' do
      user = build(:user, full_name: nil)
      expect(user).to be_valid
    end
  end
end
