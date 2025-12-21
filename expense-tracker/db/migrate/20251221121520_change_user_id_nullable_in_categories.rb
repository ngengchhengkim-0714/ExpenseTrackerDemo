class ChangeUserIdNullableInCategories < ActiveRecord::Migration[7.1]
  def change
    change_column_null :categories, :user_id, true

    # Add index for default categories (where user_id is NULL)
    add_index :categories, [:user_id, :name], unique: true, name: 'index_categories_on_user_id_and_name'
    add_index :categories, :category_type
    add_index :categories, :is_default
  end
end
