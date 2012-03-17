class CreateParagraphs < ActiveRecord::Migration
  def change
    create_table :paragraphs do |t|
      t.text :body
      t.integer :language_id
      t.integer :original_id
    end

    add_column :documents, :paragraph_id_list, :text
  end
end
