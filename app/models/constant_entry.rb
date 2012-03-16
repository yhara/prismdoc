class ConstantEntry < Entry
  belongs_to :library, class_name: "LibraryEntry"
  belongs_to :module, class_name: "ModuleEntry"

  def belong_name
    self.module.name + "::" + self.name
  end

  def path(language, version)
    self.module.path(language, version) +
      "/" + "::" + Rack::Utils.escape(self.name)
  end
end
