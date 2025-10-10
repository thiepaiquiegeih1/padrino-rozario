# encoding: utf-8
class CreateCategoriesCategorygroups < ActiveRecord::Migration
    def self.up
    create_table :categories_categorygroups, {:id => false, :force => true} do |t|
        t.integer :category_id, :null => false
        t.integer :categorygroup_id, :null => false
    end
    end

    def self.down
      drop_table :categories_categorygroups
    end
end
