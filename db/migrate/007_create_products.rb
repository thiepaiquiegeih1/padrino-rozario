# encoding: utf-8
class CreateProducts < ActiveRecord::Migration
  def self.up
create_table :products do |t|
  t.integer :category_id
      t.string :title
      t.text :announce
      t.string :image
      t.text :text
      t.string :price
      t.string :color
  t.timestamps
end
  end

  def self.down
    drop_table :products
  end
end
