# encoding: utf-8
class CreateMurmanskstreets < ActiveRecord::Migration
  def self.up
    create_table :murmanskstreets do |t|
      t.string :name
      t.integer :price
      t.boolean :free_delivery
    end
  end

  def self.down
    drop_table :murmanskstreets
  end
end
