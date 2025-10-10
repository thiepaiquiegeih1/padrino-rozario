# encoding: utf-8
class CreateUserAccounts < ActiveRecord::Migration
  def self.up
    create_table :user_accounts do |t|
      t.string :name
      t.string :surname
      t.string :tel
      t.string :address
      t.string :email
      t.string :crypted_password
      t.string :role
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
