# encoding: utf-8
# ВНИМАНИЕ: Эта миграция удаляет неиспользуемые таблицы albums и photos
# Запускать только после подтверждения, что функциональность альбомов не используется
class DropUnusedAlbumTables < ActiveRecord::Migration
  def self.up
    drop_table :photos if table_exists?(:photos)
    drop_table :albums if table_exists?(:albums)
  end

  def self.down
    create_table :albums do |t|
      t.string :title
      t.timestamps
    end
    
    create_table :photos do |t|
      t.integer :album_id
      t.string :title
      t.string :image
      t.timestamps
    end
  end
end
