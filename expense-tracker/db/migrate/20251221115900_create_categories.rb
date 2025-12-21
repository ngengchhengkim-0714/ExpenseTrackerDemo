class CreateCategories < ActiveRecord::Migration[7.1]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.string :category_type, null: false
      t.string :color, default: "#6B7280"
      t.boolean :is_default, default: false, null: false
      t.references :user, null: true, foreign_key: true

      t.timestamps
    end

    add_index :categories, [:user_id, :name], unique: true
    add_index :categories, :category_type
    add_index :categories, :is_default
  end
end
