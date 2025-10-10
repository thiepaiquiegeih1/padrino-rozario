# encoding: utf-8
class RenameOrderColumn < ActiveRecord::Migration
  def self.up
    change_table :products do |t|
      t.rename :order, :orderp
    end
  end

  def self.down
    change_table :products do |t|
      t.rename :orderp, :order
    end
  end
end
