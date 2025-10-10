# encoding: utf-8
class ExpandSubdomains < ActiveRecord::Migration
  def self.up
    add_column :subdomains, :category_ids, :string, array: true
    add_column :subdomains, :enable_categories, :boolean
    add_column :subdomains, :slideshow_main_id, :integer
    add_column :subdomains, :slideshow_cart_id, :integer
    add_column :subdomains, :enable_slideshows, :boolean
  end
end
