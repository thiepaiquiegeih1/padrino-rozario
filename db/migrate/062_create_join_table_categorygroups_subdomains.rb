# encoding: utf-8
class CreateJoinTableCategorygroupsSubdomains < ActiveRecord::Migration
    def self.up
    create_table :categorygroups_subdomains, {:id => false, :force => true} do |t|
        t.integer :categorygroup_id, :null => false
        t.integer :subdomain_id, :null => false
    end
    end

    def self.down
      drop_table :categorygroups_subdomains
    end
end
