class AddLanguagesToUsers < ActiveRecord::Migration[8.1]
  def change
    add_reference :users, :preferred_language, foreign_key: { to_table: :languages }
    add_reference :users, :native_language, foreign_key: { to_table: :languages }
    add_column :users, :name, :string
  end
end
