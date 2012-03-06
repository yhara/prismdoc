class Entry < ActiveRecord::Base
  has_many :documents
  belongs_to :superclass, class_name: "Entry" # only used for classes
  belongs_to :library,    class_name: "Entry"

  validates :name,     presence: true
  validates :fullname, presence: true, uniqueness: true

  include Enumerize
  enumerize :kind, in: ["library", "class", "module",
                        "singleton_method", "instance_method",
                        "constant"]
                          
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
    Entry.find_by_fullname!(fullname)
  end

  def self.builtin_modules
    Entry.where(library_id: Entry["_builtin"].id,
                kind: ["class", "module"]).
          order(:name).
          select{|m|
      m.superclass.nil? or m.superclass == Entry["_builtin;Object"]
    }
  end

  def self.libraries
    Entry.where(kind: "library").order(:fullname).select{|l|
      not l.name.include?("/")
    }
  end
end
