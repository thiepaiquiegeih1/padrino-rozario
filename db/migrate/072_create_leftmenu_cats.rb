# encoding: utf-8
class CreateLeftmenuCats < ActiveRecord::Migration
  def self.up
    create_table :leftmenu_cats do |t|
      t.integer :leftmenu_id
      t.integer :category_id
      t.integer :parentcat_id
      t.integer :sequence
    end
  end

  def self.down
    drop_table :leftmenu_cats
  end
end
