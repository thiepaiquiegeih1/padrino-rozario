# encoding: utf-8
class CreateFlowers < ActiveRecord::Migration
  
  def self.up
    create_table :flowers do |t|
      t.integer :product_id
      t.string :title
      t.integer :standart_count, :default => 0
      t.integer :small_count, :default => 0
      t.integer :lux_count, :default => 0
    end
  end

  def self.down
    drop_table :flowers
  end

end
