# encoding: utf-8
class CreateLeftmenus < ActiveRecord::Migration
  def self.up
    create_table :leftmenus do |t|
      t.string :title
      t.boolean :default
    end
  end

  def self.down
    drop_table :leftmenus
  end
end
