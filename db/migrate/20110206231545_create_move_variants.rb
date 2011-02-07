class CreateMoveVariants < ActiveRecord::Migration
  def self.up
    create_table :move_variants do |t|
      t.integer :base_id
      t.integer :variant_id

      t.timestamps
    end
  end

  def self.down
    drop_table :move_variants
  end
end
