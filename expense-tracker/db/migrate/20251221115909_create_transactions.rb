class CreateTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :transactions do |t|
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.text :description
      t.string :transaction_type, null: false
      t.date :date, null: false
      t.references :user, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end

    add_index :transactions, :user_id
    add_index :transactions, :category_id
    add_index :transactions, :date
    add_index :transactions, :transaction_type
    add_index :transactions, [:user_id, :date]
  end
end
