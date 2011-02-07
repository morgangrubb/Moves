class AddVariantKeysToMoves < ActiveRecord::Migration
  def self.up
    add_column :moves, :variant_keys, :text
  end

  def self.down
    remove_column :moves, :variant_keys
  end
end
