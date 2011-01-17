class AddVideoUrlToRawMoves < ActiveRecord::Migration
  def self.up
    add_column :raw_moves, :video_url, :text
  end

  def self.down
    remove_column :raw_moves, :video_url
  end
end
