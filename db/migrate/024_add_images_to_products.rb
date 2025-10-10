# encoding: utf-8
class AddImagesToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :small_image, :string
    add_column :products, :lux_image, :string
  end

  def self.down
    remove_column :products, :small_image
    remove_column :products, :lux_image
  end
end
