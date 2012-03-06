class ModuleEntry < Entry
  belongs_to :library, class_name: "LibraryEntry"
end
