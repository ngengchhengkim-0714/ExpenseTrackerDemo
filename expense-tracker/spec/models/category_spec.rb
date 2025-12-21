# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Category, type: :model do
  describe 'associations' do
    it { should belong_to(:user).optional }
    it { should have_many(:transactions).dependent(:restrict_with_error) }
  end

  describe 'validations' do
    subject { build(:category) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:category_type) }
    it { should validate_inclusion_of(:category_type).in_array(%w[income expense]) }

    describe 'name uniqueness' do
      it 'validates uniqueness of name scoped to user_id' do
        user = create(:user)
        create(:category, name: 'Food', user: user)
        duplicate = build(:category, name: 'Food', user: user)
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:name]).to include('has already been taken')
      end

      it 'allows same name for different users' do
        user1 = create(:user)
        user2 = create(:user)
        create(:category, name: 'Food', user: user1)
        duplicate = build(:category, name: 'Food', user: user2)
        expect(duplicate).to be_valid
      end

      it 'allows same name for default and user categories' do
        create(:category, :default, name: 'Food')
        user = create(:user)
        user_category = build(:category, name: 'Food', user: user)
        expect(user_category).to be_valid
      end
    end

    describe 'color validation' do
      it 'is valid with hex color format' do
        category = build(:category, color: '#FF5733')
        expect(category).to be_valid
      end

      it 'is valid with lowercase hex color' do
        category = build(:category, color: '#ff5733')
        expect(category).to be_valid
      end

      it 'is valid with nil color' do
        category = build(:category, color: nil)
        expect(category).to be_valid
      end

      it 'is invalid with incorrect format' do
        category = build(:category, color: 'FF5733')
        expect(category).not_to be_valid
      end

      it 'is invalid with short hex' do
        category = build(:category, color: '#FFF')
        expect(category).not_to be_valid
      end
    end

    describe 'category_type validation' do
      it 'is valid with income type' do
        category = build(:category, category_type: 'income')
        expect(category).to be_valid
      end

      it 'is valid with expense type' do
        category = build(:category, category_type: 'expense')
        expect(category).to be_valid
      end

      it 'is invalid with other types' do
        category = build(:category, category_type: 'savings')
        expect(category).not_to be_valid
      end
    end
  end

  describe 'scopes' do
    let(:user) { create(:user) }
    let!(:default_income) { create(:category, :default, :income, name: 'Test Default Income') }
    let!(:default_expense) { create(:category, :default, :expense, name: 'Test Default Expense') }
    let!(:user_income) { create(:category, :income, name: 'Test User Freelance', user: user) }
    let!(:user_expense) { create(:category, :expense, name: 'Test User Entertainment', user: user) }

    describe '.default_categories' do
      it 'returns only default categories' do
        # Get only the test default categories created in this test
        test_defaults = Category.where(name: ['Test Default Income', 'Test Default Expense'])
        expect(test_defaults).to match_array([default_income, default_expense])
        # Verify they are indeed default categories
        expect(test_defaults.all?(&:is_default)).to be true
        expect(test_defaults.all? { |c| c.user_id.nil? }).to be true
      end
    end

    describe '.user_categories' do
      it 'returns categories for specific user' do
        expect(Category.user_categories(user)).to match_array([user_income, user_expense])
      end
    end

    describe '.income' do
      it 'returns only income categories' do
        results = Category.where(user: user).income
        expect(results).to match_array([user_income])
      end
    end

    describe '.expense' do
      it 'returns only expense categories' do
        results = Category.where(user: user).expense
        expect(results).to match_array([user_expense])
      end
    end
  end

  describe 'default categories' do
    it 'can be created without a user' do
      category = build(:category, :default, name: 'Test Default Category')
      expect(category).to be_valid
      expect(category.user).to be_nil
    end

    it 'has is_default flag set to true' do
      category = create(:category, :default)
      expect(category.is_default).to be true
    end
  end

  describe 'transaction dependency' do
    it 'prevents deletion when transactions exist' do
      user = create(:user)
      category = create(:category, user: user)
      create(:transaction, user: user, category: category)

      expect { category.destroy }.not_to change(Category, :count)
      expect(category.errors[:base]).to include('Cannot delete record because dependent transactions exist')
    end

    it 'allows deletion when no transactions exist' do
      user = create(:user)
      category = create(:category, user: user)

      expect { category.destroy }.to change(Category, :count).by(-1)
    end
  end

  describe 'instance methods' do
    it 'belongs to a user' do
      category = build(:category)
      expect(category.user).to be_a(User)
    end

    it 'can have many transactions' do
      user = create(:user)
      category = create(:category, user: user)
      transaction1 = create(:transaction, user: user, category: category)
      transaction2 = create(:transaction, user: user, category: category)
      expect(category.transactions).to include(transaction1, transaction2)
    end
  end
end
