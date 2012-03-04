class CreateModels < ActiveRecord::Migration
  def change
    create_table :languages do |t|
      t.string :english_name
      t.string :native_name
      t.string :short_name
    end

    create_table :entries do |t|
      t.string :name
      t.string :fullname
      t.string :kind

      t.integer :superclass_id  # for classes
      t.integer :library_id     # for classes,modules
    end

    create_table :documents do |t|
      t.integer :entry_id
      t.integer :language_id
      t.text :body
    end
  end
end
