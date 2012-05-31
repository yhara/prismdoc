class AddVersionIdToEntries < ActiveRecord::Migration
  def change
    add_column :entries, :version_id, :integer
  end
end
