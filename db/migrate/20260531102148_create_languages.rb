class CreateLanguages < ActiveRecord::Migration[8.1]
  def change
    create_table :languages do |t|
      t.string :name
      t.string :code
      t.string :native_name

      t.timestamps
    end
  end
end
