# encoding: utf-8
class CreateDisabledDates < ActiveRecord::Migration
  def change
    create_table :disabled_dates do |t|
      t.string :name
      t.datetime :date, null: false
      t.timestamps null: false
      t.boolean :enabled, null: false, default: false
      t.boolean :only_delivery, null: false, default: false
      t.boolean :except_delivery, null: false, default: false
    end
    create_table :disabled_dates_subdomains, id: false do |t|
      t.integer :disabled_date_id, null: false, index: true
      t.integer :subdomain_id, null: false, index: true
    end
  end
end
