# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Transactions', type: :request do
  let(:user) { create(:user, password: 'Password123!') }
  let(:category) { create(:category, user: user) }
  let(:valid_attributes) do
    {
      amount: 100.50,
      description: 'Test transaction',
      transaction_type: 'expense',
      date: Date.today,
      category_id: category.id
    }
  end
  let(:invalid_attributes) do
    {
      amount: -10,
      description: 'Invalid transaction',
      transaction_type: 'invalid_type',
      date: Date.today,
      category_id: category.id
    }
  end

  before { sign_in user }

  describe 'GET /transactions' do
    let!(:transactions) { create_list(:transaction, 5, user: user, category: category) }

    it 'returns success' do
      get transactions_path
      expect(response).to have_http_status(:success)
    end

    it 'displays all user transactions' do
      get transactions_path
      transactions.each do |transaction|
        expect(response.body).to include(transaction.description)
      end
    end

    context 'with filtering' do
      let(:income_category) { create(:category, user: user, category_type: 'income') }
      let!(:income_transaction) { create(:transaction, user: user, category: income_category, transaction_type: 'income', description: 'Salary') }
      let!(:expense_transaction) { create(:transaction, user: user, category: category, transaction_type: 'expense', description: 'Groceries') }

      it 'filters by transaction type' do
        get transactions_path, params: { type: 'income' }
        expect(response.body).to include('Salary')
        expect(response.body).not_to include('Groceries')
      end

      it 'filters by category' do
        get transactions_path, params: { category_id: income_category.id }
        expect(response.body).to include('Salary')
      end
    end
  end

  describe 'GET /transactions/:id' do
    let(:transaction) { create(:transaction, user: user, category: category) }

    it 'returns success' do
      get transaction_path(transaction)
      expect(response).to have_http_status(:success)
    end

    it 'displays transaction details' do
      get transaction_path(transaction)
      expect(response.body).to include(transaction.description)
      expect(response.body).to include(transaction.amount.to_s)
    end

    context 'when transaction belongs to another user' do
      let(:other_user) { create(:user) }
      let(:other_transaction) { create(:transaction, user: other_user) }

      it 'returns not found' do
        expect {
          get transaction_path(other_transaction)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'GET /transactions/new' do
    it 'returns success' do
      get new_transaction_path
      expect(response).to have_http_status(:success)
    end

    it 'displays the form' do
      get new_transaction_path
      expect(response.body).to include('form')
    end
  end

  describe 'POST /transactions' do
    context 'with valid parameters' do
      it 'creates a new transaction' do
        expect {
          post transactions_path, params: { transaction: valid_attributes }
        }.to change(Transaction, :count).by(1)
      end

      it 'redirects to the transactions list' do
        post transactions_path, params: { transaction: valid_attributes }
        expect(response).to redirect_to(transactions_path)
      end

      it 'sets the success flash message' do
        post transactions_path, params: { transaction: valid_attributes }
        follow_redirect!
        expect(response.body).to include('Transaction was successfully created')
      end

      it 'associates transaction with current user' do
        post transactions_path, params: { transaction: valid_attributes }
        expect(Transaction.last.user).to eq(user)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new transaction' do
        expect {
          post transactions_path, params: { transaction: invalid_attributes }
        }.not_to change(Transaction, :count)
      end

      it 'renders the new template' do
        post transactions_path, params: { transaction: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'displays error messages' do
        post transactions_path, params: { transaction: invalid_attributes }
        expect(response.body).to include('error')
      end
    end
  end

  describe 'GET /transactions/:id/edit' do
    let(:transaction) { create(:transaction, user: user, category: category) }

    it 'returns success' do
      get edit_transaction_path(transaction)
      expect(response).to have_http_status(:success)
    end

    it 'displays the edit form' do
      get edit_transaction_path(transaction)
      expect(response.body).to include('form')
      expect(response.body).to include(transaction.description)
    end
  end

  describe 'PATCH /transactions/:id' do
    let(:transaction) { create(:transaction, user: user, category: category) }
    let(:new_attributes) { { amount: 200.00, description: 'Updated description' } }

    context 'with valid parameters' do
      it 'updates the transaction' do
        patch transaction_path(transaction), params: { transaction: new_attributes }
        transaction.reload
        expect(transaction.amount).to eq(200.00)
        expect(transaction.description).to eq('Updated description')
      end

      it 'redirects to the transaction' do
        patch transaction_path(transaction), params: { transaction: new_attributes }
        expect(response).to redirect_to(transactions_path)
      end

      it 'sets the success flash message' do
        patch transaction_path(transaction), params: { transaction: new_attributes }
        follow_redirect!
        expect(response.body).to include('Transaction was successfully updated')
      end
    end

    context 'with invalid parameters' do
      it 'does not update the transaction' do
        original_amount = transaction.amount
        patch transaction_path(transaction), params: { transaction: { amount: -100 } }
        transaction.reload
        expect(transaction.amount).to eq(original_amount)
      end

      it 'renders the edit template' do
        patch transaction_path(transaction), params: { transaction: { amount: -100 } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'DELETE /transactions/:id' do
    let!(:transaction) { create(:transaction, user: user, category: category) }

    it 'destroys the transaction' do
      expect {
        delete transaction_path(transaction)
      }.to change(Transaction, :count).by(-1)
    end

    it 'redirects to transactions list' do
      delete transaction_path(transaction)
      expect(response).to redirect_to(transactions_path)
    end

    it 'sets the success flash message' do
      delete transaction_path(transaction)
      follow_redirect!
      expect(response.body).to include('Transaction was successfully deleted')
    end
  end

  describe 'GET /transactions/summary' do
    let!(:income_transactions) { create_list(:transaction, 3, :income, user: user, amount: 100) }
    let!(:expense_transactions) { create_list(:transaction, 2, :expense, user: user, amount: 50) }

    it 'returns success' do
      get summary_transactions_path
      expect(response).to have_http_status(:success)
    end

    it 'calculates total income' do
      get summary_transactions_path
      # Should show income total of 300 (3 x 100)
      expect(response.body).to include('300')
    end

    it 'calculates total expenses' do
      get summary_transactions_path
      # Should show expense total of 100 (2 x 50)
      expect(response.body).to include('100')
    end
  end

  context 'when not signed in' do
    before { sign_out user }

    it 'redirects to sign in page' do
      get transactions_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
