# encoding: utf-8
class AddDefaultPriceAndImageToProducts< ActiveRecord::Migration
  def self.up
    add_column :products, :default_image, :integer
    add_column :products, :default_price, :integer
  end

  def self.down
    remove_column :products, :default_image
    remove_column :products, :default_price
  end
end
