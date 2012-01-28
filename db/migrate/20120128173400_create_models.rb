class CreateModels < ActiveRecord::Migration
  def change
    create_table :languages do |t|
      t.string :english_name
      t.string :native_name
    end

    create_table :entry_types do |t|
      t.string :name
    end

    create_table :entries do |t|
      t.string :name
      t.string :fullname
      t.integer :entry_type_id
    end

    create_table :documents do |t|
      t.integer :entry_id
      t.integer :language_id
      t.text :body
    end
  end
end
