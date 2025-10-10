# encoding: utf-8
class CreateTagComplects < ActiveRecord::Migration
  def self.up
    create_table :tag_complects do |t|
      t.integer :product_id, index: true
      t.integer :complect_id, index: true
      t.integer :tag_id, index: true
      t.integer :count
      t.timestamps
    end
  end

  def self.down
    drop_table :tag_complects
  end
end
