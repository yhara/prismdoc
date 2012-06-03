class RemoveVersionIdFromDocuments < ActiveRecord::Migration
  def up
    remove_column :documents, :version_id
  end

  def down
    add_column :documents, :version_id, :integer
  end
end
