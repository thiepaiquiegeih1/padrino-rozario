# encoding: utf-8
class AddDefaultOrdersToProducts < ActiveRecord::Migration
  def self.up
    Category.find_each do |c|
      c.products.each_with_index do |x, i|
        x.order = i
        x.save
      end
    end
  end

  def self.down
  end
end
