class AddPositionToMoveBeats < ActiveRecord::Migration
  def self.up
    add_column :move_beats, :position, :integer, :null => false, :default => 0
    
    # Now we have to load and sort all of the beats
    Move.all.each &:order_beats!
  end

  def self.down
    remove_column :move_beats, :position
  end
end
