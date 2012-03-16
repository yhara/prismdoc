class CreateVersions < ActiveRecord::Migration
  def change
    create_table :versions do |t|
      t.string :name
    end

    add_column :documents, :version_id, :integer
  end
end
