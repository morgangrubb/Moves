class AddFieldsToMoves < ActiveRecord::Migration
  def self.up
    add_column :moves, :lead_start_hand_id, :integer
    add_column :moves, :lead_finish_hand_id, :integer
    add_column :moves, :follow_start_hand_id, :integer
    add_column :moves, :follow_finish_hand_id, :integer
    add_column :moves, :spins, :boolean
    add_column :moves, :beats, :integer
    add_column :moves, :category_id, :integer
    add_column :moves, :difficulty_id, :integer
  end

  def self.down
    remove_column :moves, :difficulty_id
    remove_column :moves, :category_id
    remove_column :moves, :beats
    remove_column :moves, :spins
    remove_column :moves, :follow_finish_hand_id
    remove_column :moves, :follow_start_hand_id
    remove_column :moves, :lead_finish_hand_id
    remove_column :moves, :lead_start_hand_id
  end
end
