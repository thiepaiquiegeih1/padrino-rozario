# encoding: utf-8
class AddOrderToProducts < ActiveRecord::Migration
  def self.up
    change_table :products do |t|
      t.integer :order, default: 1000
    end
  end

  def self.down
    change_table :products do |t|
      t.remove :order
    end
  end
end
