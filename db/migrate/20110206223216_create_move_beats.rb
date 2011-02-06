class CreateMoveBeats < ActiveRecord::Migration
  def self.up
    create_table :move_beats do |t|
      t.integer :move_id, :null => false
      t.string :beat
      t.text :description

      t.timestamps
    end
    
    add_index :move_beats, :move_id
  end

  def self.down
    drop_table :move_beats
  end
end
