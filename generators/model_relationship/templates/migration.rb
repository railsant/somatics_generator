class <%= migration_name.camelize %> < ActiveRecord::Migration
  def self.up
    add_column :<%= table_name %>, :<%= attribute %>, :integer
    add_index :<%= table_name %>, :<%= attribute %>
  end

  def self.down
    remove_index :<%= table_name %>, :<%= attribute %>
    remove_column :<%= table_name %>, :<%= attribute %>
  end
end