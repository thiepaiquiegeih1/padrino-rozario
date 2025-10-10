# encoding: utf-8
class CreateSubdomainPools < ActiveRecord::Migration
    def self.up
      create_table :subdomain_pools do |t|
        t.string :name
        t.timestamps
      end
    end

    def self.down
      drop_table :subdomain_pools
    end
end
