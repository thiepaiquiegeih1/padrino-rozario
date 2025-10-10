# encoding: utf-8
class AddLeftmenuColumn < ActiveRecord::Migration
  def self.up
    add_column :subdomains, :leftmenu_id, :integer
    add_column :subdomain_pools,  :leftmenu_id, :integer
  end

  def self.down
    remove_column :subdomains, :leftmenu_id
    remove_column :subdomain_pools,  :leftmenu_id
  end
end
