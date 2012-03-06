class ClassEntry < ModuleEntry
  belongs_to :superclass, class_name: "ClassEntry"
end
