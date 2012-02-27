class AddKindToEntries < ActiveRecord::Migration
  def change
    add_column :entries, :kind, :string
  end
end
