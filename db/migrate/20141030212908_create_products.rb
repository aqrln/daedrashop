class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :title
      t.integer :views
      t.float :price

      t.timestamps
    end
  end
end
