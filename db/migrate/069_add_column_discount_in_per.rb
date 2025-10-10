# encoding: utf-8
class AddColumnDiscountInPer < ActiveRecord::Migration
  def self.up
    add_column :categories_subdomains, :discount_in_percents, :integer, default: 0
    add_column :categories_subdomain_pools,  :discount_in_percents, :integer, default: 0
    add_column :categories,  :discount_in_percents, :integer, default: 0
  end

  def self.down
    remove_column :categories_subdomains, :discount_in_percents
    remove_column :categories_subdomain_pools,  :discount_in_percents
    remove_column :categories,  :discount_in_percents
  end

end
