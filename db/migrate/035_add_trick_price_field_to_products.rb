# encoding: utf-8
class AddTrickPriceFieldToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :trick_price, :boolean
  end

  def self.down
    remove_column :products, :trick_price
  end
end
