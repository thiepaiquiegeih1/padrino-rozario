# encoding: utf-8
class AddPricesToProduct < ActiveRecord::Migration
  class Product < ActiveRecord::Base
  end
  def self.up
    add_column :products, :small_price, :decimal
    add_column :products, :lux_price, :decimal

    Product.find_each do |product|
      price = product.price
      product.small_price = price * 0.6
      product.lux_price = price * 1.4
      product.save!
    end
  end

  def self.down
    remove_column :products, :lux_price
    remove_column :products, :small_price
  end
end
