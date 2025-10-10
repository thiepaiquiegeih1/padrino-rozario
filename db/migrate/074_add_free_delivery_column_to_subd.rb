# encoding: utf-8
class AddFreeDeliveryColumnToSubd < ActiveRecord::Migration
  def self.up
      change_table :subdomains do |t|
          t.boolean :free_delivery
          t.integer :freedelivery_summ, :default => 1500
      end
  end

  def self.down
    change_table :subdomains do |t|
       t.remove :free_delivery
       t.remove :freedelivery_summ
    end
  end
end
