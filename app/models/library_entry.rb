class LibraryEntry < Entry
  has_many :modules, class_name: "ModuleEntry", foreign_key: "library_id"
  def path(language)
    [ 
      "/", Rack::Utils.escape(language.short_name),
      (if self.name == "_builtin"
         ""
       else
         "/" + Rack::Utils.escape(self.fullname)
       end)
    ].join
  end
end
