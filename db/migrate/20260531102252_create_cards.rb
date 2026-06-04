class CreateCards < ActiveRecord::Migration[8.1]
  def change
    create_table :cards do |t|
      t.text :front_text
      t.text :back_text
      t.references :user, null: false, foreign_key: true
      t.references :collection, null: false, foreign_key: true
      t.references :source_language, null: false, foreign_key: { to_table: :languages }
      t.references :target_language, null: false, foreign_key: { to_table: :languages }

      t.timestamps
    end
  end
end
