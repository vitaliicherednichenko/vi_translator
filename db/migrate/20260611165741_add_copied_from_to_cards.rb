class AddCopiedFromToCards < ActiveRecord::Migration[8.1]
  def change
    add_column :cards, :copied_from_id, :integer
    add_index :cards, :copied_from_id
  end
end
