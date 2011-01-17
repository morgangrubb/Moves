class CreateRawMoves < ActiveRecord::Migration
  def self.up
    create_table :raw_moves do |t|
      t.text :url
      t.string :title
      t.text :link_data
      t.text :body
      t.timestamps
    end
  end

  def self.down
    drop_table :raw_moves
  end
end
