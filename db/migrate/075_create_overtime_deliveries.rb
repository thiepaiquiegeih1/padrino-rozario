# encoding: utf-8
class CreateOvertimeDeliveries < ActiveRecord::Migration
  def self.up
    create_table :overtime_deliveries do |t|
      t.string :title
      t.integer :price
      t.boolean :onetime_event
      t.boolean :eachday_repeat
      t.boolean :eachyear_repeat
      t.time :start_time
      t.time :end_time
      t.date :start_date
      t.date :end_date
    end
  end

  def self.down
    drop_table :overtime_deliveries
  end
end
