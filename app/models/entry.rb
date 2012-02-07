class Entry < ActiveRecord::Base
  has_many :documents
  belongs_to :entry_type

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

  # Shortcut to an instance of Entry.
  # Useful in rails console (eg. Entry["Array#map!"])
  def self.[](fullname)
    Entry.find_by_fullname(fullname)
  end

  def self.classes_modules
    Entry.where(entry_type_id: [EntryType["class"].id,
                                EntryType["module"].id])
  end
end
