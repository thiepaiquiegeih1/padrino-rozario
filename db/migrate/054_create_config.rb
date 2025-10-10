# encoding: utf-8
class CreateConfig < ActiveRecord::Migration
  def self.up
    create_table :general_configs do |t|
      t.string :name
      t.string :value
      t.timestamps
    end
  end
end
