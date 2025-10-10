# encoding: utf-8
class CreateCategories < ActiveRecord::Migration
  
  def self.up
    create_table :categories do |t|
      t.string :title
      t.text :announce
      t.string :image
      t.text :text
      t.string :template
      t.boolean :show_in_index
      t.integer :parent_id
      t.timestamps
    end
  end

  def self.down
    drop_table :categories
  end

end