# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Transaction, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:category) }
  end

  describe 'validations' do
    subject { build(:transaction) }

    it { should validate_presence_of(:amount) }
    it { should validate_numericality_of(:amount).is_greater_than(0) }
    it { should validate_length_of(:description).is_at_most(500) }
    it { should validate_presence_of(:transaction_type) }
    it { should validate_inclusion_of(:transaction_type).in_array(%w[income expense]) }
    it { should validate_presence_of(:date) }

    describe 'date_not_in_future' do
      it 'is valid with today date' do
        transaction = build(:transaction, date: Date.today)
        expect(transaction).to be_valid
      end

      it 'is valid with past date' do
        transaction = build(:transaction, date: 1.day.ago)
        expect(transaction).to be_valid
      end

      it 'is invalid with future date' do
        transaction = build(:transaction, date: 1.day.from_now)
        expect(transaction).not_to be_valid
        expect(transaction.errors[:date]).to include('cannot be in the future')
      end
    end

    describe 'amount validation' do
      it 'is invalid with zero amount' do
        transaction = build(:transaction, amount: 0)
        expect(transaction).not_to be_valid
      end

      it 'is invalid with negative amount' do
        transaction = build(:transaction, amount: -10.50)
        expect(transaction).not_to be_valid
      end

      it 'is valid with positive amount' do
        transaction = build(:transaction, amount: 100.50)
        expect(transaction).to be_valid
      end
    end

    describe 'transaction_type validation' do
      it 'is valid with income type' do
        transaction = build(:transaction, transaction_type: 'income')
        expect(transaction).to be_valid
      end

      it 'is valid with expense type' do
        transaction = build(:transaction, transaction_type: 'expense')
        expect(transaction).to be_valid
      end

      it 'is invalid with invalid type' do
        transaction = build(:transaction, transaction_type: 'invalid')
        expect(transaction).not_to be_valid
      end
    end
  end

  describe 'scopes' do
    let(:user) { create(:user) }
    let(:category_income) { create(:category, user: user, category_type: 'income') }
    let(:category_expense) { create(:category, user: user, category_type: 'expense') }

    let!(:income1) { create(:transaction, user: user, category: category_income, transaction_type: 'income', amount: 1000, date: 5.days.ago) }
    let!(:income2) { create(:transaction, user: user, category: category_income, transaction_type: 'income', amount: 500, date: 10.days.ago) }
    let!(:expense1) { create(:transaction, user: user, category: category_expense, transaction_type: 'expense', amount: 200, date: 3.days.ago) }
    let!(:expense2) { create(:transaction, user: user, category: category_expense, transaction_type: 'expense', amount: 150, date: 7.days.ago) }

    describe '.recent' do
      it 'returns transactions ordered by date desc, then created_at desc' do
        expect(Transaction.where(user: user).recent).to eq([expense1, income1, expense2, income2])
      end
    end

    describe '.by_type' do
      it 'returns only income transactions' do
        expect(Transaction.where(user: user).by_type('income')).to match_array([income1, income2])
      end

      it 'returns only expense transactions' do
        expect(Transaction.where(user: user).by_type('expense')).to match_array([expense1, expense2])
      end
    end

    describe '.by_category' do
      it 'returns transactions for specific category' do
        expect(user.transactions.by_category(category_income.id)).to match_array([income1, income2])
      end
    end

    describe '.by_date_range' do
      it 'returns transactions within date range' do
        start_date = 8.days.ago.to_date
        end_date = 4.days.ago.to_date
        expect(Transaction.where(user: user).by_date_range(start_date, end_date)).to match_array([income1, expense2])
      end
    end

    describe '.income' do
      it 'returns only income transactions' do
        expect(Transaction.where(user: user).income).to match_array([income1, income2])
      end
    end

    describe '.expense' do
      it 'returns only expense transactions' do
        expect(Transaction.where(user: user).expense).to match_array([expense1, expense2])
      end
    end
  end

  describe 'instance methods' do
    let(:transaction) { build(:transaction, amount: 123.45, transaction_type: 'expense') }

    it 'stores decimal amounts correctly' do
      transaction.save
      expect(transaction.reload.amount).to eq(123.45)
    end

    it 'belongs to a user' do
      expect(transaction.user).to be_a(User)
    end

    it 'belongs to a category' do
      expect(transaction.category).to be_a(Category)
    end
  end
end
