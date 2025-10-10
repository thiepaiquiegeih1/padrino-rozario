# encoding: utf-8
class CreateJoinTableCategorygroupsSubdomainPools < ActiveRecord::Migration
    def self.up
    create_table :categorygroups_subdomain_pools, {:id => false, :force => true} do |t|
        t.integer :categorygroup_id, :null => false
        t.integer :subdomain_pool_id, :null => false
    end
    end

    def self.down
      drop_table :categorygroups_subdomain_pools
    end
end
