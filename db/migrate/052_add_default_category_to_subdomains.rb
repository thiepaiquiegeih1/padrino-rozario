# encoding: utf-8
class AddDefaultCategoryToSubdomains < ActiveRecord::Migration
  def self.up
    add_column :subdomains, :category_menu_ids, :string, default: ''
    add_column :subdomains, :default_category_id, :integer, default: 118
    add_column :subdomains, :coop_clients, :boolean
  end
end
