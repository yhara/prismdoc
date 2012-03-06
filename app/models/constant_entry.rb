class ConstantEntry < Entry
  belongs_to :library, class_name: "LibraryEntry"
  belongs_to :module, class_name: "ModuleEntry"
end
