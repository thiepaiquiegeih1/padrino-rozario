# encoding: utf-8
class AddCrosssellcatToSubdomainPool < ActiveRecord::Migration
  def self.up
      change_table :subdomain_pools do |t|
          t.integer :crosssel_categorygroup_id

      end
  end

  def self.down
    change_table :subdomain_pools do |t|
       t.remove :crosssel_categorygroup_id
    end
  end
end
