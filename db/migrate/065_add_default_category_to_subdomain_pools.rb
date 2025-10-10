# encoding: utf-8
class AddDefaultCategoryToSubdomainPools < ActiveRecord::Migration
    def self.up
        change_table :subdomain_pools do |t|
            t.integer :default_category_id
            t.boolean :enable_categories
            t.boolean :coop_clients
        end
    end

    def self.down
      change_table :subdomain_pools do |t|
         t.remove :default_category_id
         t.remove :enable_categories
         t.remove :coop_clients
      end
    end
end
