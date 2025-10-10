# encoding: utf-8
class CreateDiscountPeriods < ActiveRecord::Migration
  def self.up
    create_table :discount_periods do |t|
      t.string :title
      t.boolean :eachyear_repeat
      t.date :start_date
      t.date :end_date
    end
  end

  def self.down
    drop_table :discount_periods
  end
end
