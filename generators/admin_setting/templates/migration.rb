class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    create_table "<%= table_name %>" do |t|
      t.string :name
      t.string :field_type
      t.text :value
      t.string :category
      t.text :description
      t.boolean :mce_editable
    end
    add_index :<%= table_name %>, :name, :unique => true
  end

  def self.down
    drop_table "<%= table_name %>"
  end
end
