class RemoveEntryTypeIdFromEntries < ActiveRecord::Migration
  def up
    remove_column :entries, :entry_type_id
  end

  def down
    add_column :entries, :entry_type_id, :integer
  end
end
