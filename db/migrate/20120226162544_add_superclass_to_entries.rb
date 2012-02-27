class AddSuperclassToEntries < ActiveRecord::Migration
  def change
    add_column :entries, :superclass_id, :integer
  end
end
