# encoding: utf-8
class CreateJoinTableCategoriesSubdomains < ActiveRecord::Migration
    def self.up
    create_table :categories_subdomains, {:id => false, :force => true} do |t|
        t.integer :category_id, :null => false
        t.integer :subdomain_id, :null => false
    end
    end

    def self.down
      drop_table :categories_subdomains
    end
end
