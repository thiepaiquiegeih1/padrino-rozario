# encoding: utf-8
class AddOrderIdToSmiles < ActiveRecord::Migration
  def self.up
    add_column :smiles, :order_id, :integer
    add_index :smiles, :order_id
  end

  def self.down
    remove_column :smiles, :order_id
  end
end
