class LibraryEntry < Entry
  has_many :modules, class_name: "ModuleEntry", foreign_key: "library_id"
  def path(language, version)
    [ 
      "/", Rack::Utils.escape(language.short_name),
      "/", Rack::Utils.escape(version.name),
      (if self.name == "_builtin"
         ""
       else
         "/" + Rack::Utils.escape(self.fullname)
       end)
    ].join
  end

  def belong_name
    self.name
  end
end
