# encoding: utf-8
class CreateComplects < ActiveRecord::Migration
  def self.up
    create_table :complects do |t|
      t.string :title
      t.timestamps
    end
  end

  def self.down
    drop_table :complects
  end
end
