# encoding: utf-8
class RemoveHardcodedPricesAndImagesFromProducts < ActiveRecord::Migration
  def self.up
    remove_column(:products, :lux_price)
    remove_column(:products, :small_price)
    remove_column(:products, :price)
    remove_column(:products, :lux_image)
    remove_column(:products, :small_image)
    remove_column(:products, :image)
  end

  def self.down
    add_column :products, :small_image, :string
    add_column :products, :lux_image, :string
    add_column :products, :image, :string
    add_column :products, :small_price, :decimal
    add_column :products, :lux_price, :decimal
    add_column :products, :price, :decimal
  end
end
