class ModuleEntry < Entry
  belongs_to :library, class_name: "LibraryEntry"
  has_many :methods, class_name: "MethodEntry",
    foreign_key: "module_id"
  has_many :singleton_methods, class_name: "SingletonMethodEntry",
    foreign_key: "module_id"
  has_many :instance_methods, class_name: "InstanceMethodEntry",
    foreign_key: "module_id"
  has_many :constants, class_name: "ConstantEntry",
    foreign_key: "module_id"

  def path(language)
    self.library.path(language) +
      "/" + Rack::Utils.escape(self.name)
  end
end
