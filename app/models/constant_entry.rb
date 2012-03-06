class ConstantEntry < Entry
  belongs_to :library, class_name: "LibraryEntry"
  belongs_to :module, class_name: "ModuleEntry"

  def path(language)
    self.module.path(language) +
      "/" + "." + Rack::Utils.escape(self.name)
  end
end
