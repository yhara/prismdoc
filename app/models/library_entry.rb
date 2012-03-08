class LibraryEntry < Entry
  has_many :modules, class_name: "ModuleEntry", foreign_key: "library_id"
  def path(language)
    return "/" if self.name == "_builtin"

    [ 
      "/", Rack::Utils.escape(language.short_name),
      "/", Rack::Utils.escape(self.fullname)
    ].join
  end
end
