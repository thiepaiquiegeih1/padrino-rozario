# encoding: utf-8
class CreateRemember < ActiveRecord::Migration
  def self.up
    create_table :remembers do |t|
      t.integer :user_account_id, null: false
      t.integer :order_id
      t.datetime :notificate_at
      t.datetime :order_date
      t.timestamps
    end
  end

  def self.down
    drop_table :remembers
  end
end
