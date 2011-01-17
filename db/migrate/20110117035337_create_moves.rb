class CreateMoves < ActiveRecord::Migration
  def self.up
    create_table :moves do |t|
      t.string :name, :null => false
      t.text :url, :null => false
      t.text :movie_url, :null => true
      t.boolean :local_movie, :default => false, :null => false

      t.timestamps
    end
    
    add_index :moves, :url, :unique => true
  end

  def self.down
    drop_table :moves
  end
end
