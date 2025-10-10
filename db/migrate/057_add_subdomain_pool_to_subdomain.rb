# encoding: utf-8
class AddSubdomainPoolToSubdomain < ActiveRecord::Migration
  def self.up
    change_table :subdomains do |t|
      t.references :subdomain_pool
    end
  end

  def self.down
    change_table :subdomains do |t|
      t.remove :subdomain_pool
    end
  end
end
