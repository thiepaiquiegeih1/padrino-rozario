# encoding: utf-8
class CreateJoinTableCategoriesSubdomainPools < ActiveRecord::Migration
    def self.up
    create_table :categories_subdomain_pools, {:id => false, :force => true} do |t|
        t.integer :category_id, :null => false
        t.integer :subdomain_pool_id, :null => false
    end
    end

    def self.down
      drop_table :categories_subdomain_pools
    end
end
