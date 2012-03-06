class Entry < ActiveRecord::Base
  has_many :documents

  validates :name,     presence: true
  validates :fullname, presence: true, uniqueness: true

  # Shortcut to an instance of Entry.
  # Useful in rails console (eg. Entry["Array#map!"])
  def self.[](fullname)
    Entry.find_by_fullname!(fullname)
  end

  def self.builtin_modules
    ModuleEntry.where(library_id: Entry["_builtin"].id).
          order(:name).
          select{|m|
            !m.is_a?(ClassEntry) || m.superclass == Entry["_builtin;Object"]
          }
  end

  def self.libraries
    LibraryEntry.order(:fullname).select{|l|
      not l.name.include?("/")
    }
  end
end
