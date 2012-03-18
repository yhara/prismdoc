class AddTranslatedToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :translated, :string,
      null: false, default: "no"
  end
end
