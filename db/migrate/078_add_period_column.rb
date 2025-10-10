# encoding: utf-8
class AddPeriodColumn < ActiveRecord::Migration
  def self.up
    change_table :categories_subdomains do |t|
      t.boolean :discount_status,  :default => false
      t.integer :discount_period_id,  :default => 0
    end
  end

  def self.down
    change_table :categories_subdomains do |t|
      t.remove :discount_status
      t.remove :discount_period_id
    end
  end
end
