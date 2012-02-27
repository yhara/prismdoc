class Entry < ActiveRecord::Base
  has_many :documents
  belongs_to :entry_type
  belongs_to :superclass, class_name: "Entry" # only used for classes

  validates :name,     presence: true
  validates :fullname, presence: true, uniqueness: true

  # Returns a string like "class", "instance_method", etc.
  def type
    self.entry_type.name
  end

  # Returns the class name part of the fullname.
  # Only meaningful for method entries
  #
  # eg. Returns a string "Array" for entry of Array#each
  def class_name
    self.fullname[/\A(.*)([\.\#])([^\.\#]+)\z/, 1]
  end

  # Returns the method name part of the fullname.
  # Only meaningful for method entries
  #
  # eg. Returns a string "each" for entry of Array#each
  def method_name
    self.fullname[/\A(.*)([\.\#])([^\.\#]+)\z/, 3]
  end

  def inspect
    "#<Entry(#{entry_type.name}) id: #{id}, name: #{name}, fullname: #{fullname.inspect}>"
  end

  # Shortcut to an instance of Entry.
  # Useful in rails console (eg. Entry["Array#map!"])
  def self.[](fullname)
    Entry.find_by_fullname!(fullname)
  end

  def self.find_by_type(*type_names)
    Entry.where(entry_type_id: type_names.map{|n| EntryType[n].id})
  end

  def self.classes_modules
    find_by_type("class", "module").select{|m|
      m.superclass.nil? or m.superclass == Entry["Object"]
    }
  end

  def self.libraries
    find_by_type("library")
  end
end
