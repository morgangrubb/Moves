class CreateAttributes < ActiveRecord::Migration
  def self.up
    create_table :attributes do |t|
      t.string :type
      t.string :name

      t.timestamps
    end
    
    add_index :attributes, :type
  end

  def self.down
    drop_table :attributes
  end
end
