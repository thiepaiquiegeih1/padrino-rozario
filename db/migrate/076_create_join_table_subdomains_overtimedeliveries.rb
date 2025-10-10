# encoding: utf-8
class CreateJoinTableSubdomainsOvertimedeliveries < ActiveRecord::Migration
  def self.up
  create_table :subdomains_overtimedeliveries, {:id => false, :force => true} do |t|
      t.integer :overtime_delivery_id, :null => false
      t.integer :subdomain_id, :null => false
  end
  end

  def self.down
    drop_table :subdomains_overtimedeliveries
  end
end
