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
      t.string :type

      t.integer :superclass_id  # only: classes
      t.integer :module_id      # except: libraries, modules
      t.integer :library_id     # except: libraries 
    end

    create_table :documents do |t|
      t.integer :entry_id
      t.integer :language_id
      t.text :body
    end
  end
end
