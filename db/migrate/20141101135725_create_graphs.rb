class CreateGraphs < ActiveRecord::Migration
  def change
    create_table :graphs do |t|
      t.integer :first_product
      t.integer :second_product
      t.integer :buy_with
      t.integer :view_with
      t.integer :cart_with

      t.timestamps
    end
  end
end
