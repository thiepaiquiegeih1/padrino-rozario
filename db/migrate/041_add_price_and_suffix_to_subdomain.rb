# encoding: utf-8
class AddPriceAndSuffixToSubdomain < ActiveRecord::Migration
  def self.up
    change_table :subdomains do |t|
      t.integer :price
      t.string :suffix
    end
  end

  def self.down
    change_table :subdomains do |t|
      t.remove :price
      t.remove :suffix
    end
  end
end
