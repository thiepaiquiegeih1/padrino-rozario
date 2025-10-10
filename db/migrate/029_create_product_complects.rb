# encoding: utf-8
class CreateProductComplects < ActiveRecord::Migration
  def self.up
    create_table :product_complects do |t|
      t.integer :product_id, index: true
      t.integer :complect_id, index: true
      t.decimal :price
      t.string :image
      t.timestamps
    end
  end

  def self.down
    drop_table :product_complects
  end
end
