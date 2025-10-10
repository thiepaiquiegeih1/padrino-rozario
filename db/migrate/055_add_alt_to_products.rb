# encoding: utf-8
class AddAltToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :alt, :string
  end
end
