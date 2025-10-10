# encoding: utf-8
class AddHeaderAndDescriptionToProduct < ActiveRecord::Migration
  def self.up
    change_table :products do |t|
      t.string :header
      t.string :description
    end
    Product.update_all('header=title')
  end

  def self.down
    change_table :products do |t|
      t.remove :header
      t.remove :description
    end
  end
end
