# encoding: utf-8
class AddColumnDiscountInRu < ActiveRecord::Migration
  def self.up
    add_column :categories_subdomains, :discount_in_rubles, :integer, default: 0
    add_column :categories_subdomain_pools,  :discount_in_rubles, :integer, default: 0
    add_column :categories,  :discount_in_rubles, :integer, default: 0
  end

  def self.down
    remove_column :categories_subdomains, :discount_in_rubles
    remove_column :categories_subdomain_pools,  :discount_in_rubles
    remove_column :categories,  :discount_in_rubles
  end
end
