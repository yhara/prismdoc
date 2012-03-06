class MethodEntry < Entry
  belongs_to :library, class_name: "LibraryEntry"
  belongs_to :module, class_name: "ModuleEntry"

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
end
