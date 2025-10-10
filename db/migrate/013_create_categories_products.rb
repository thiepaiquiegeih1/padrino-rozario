# encoding: utf-8
class CreateCategoriesProducts < ActiveRecord::Migration
  def self.up
	create_table :categories_products, {:id => false, :force => true} do |t|
      t.integer :category_id
      t.integer :product_id
	end
  end

  def self.down
    drop_table :categories_products
  end
end
