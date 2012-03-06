class LibraryEntry < Entry
  def path(language)
    return "/" if self.name == "_builtin"

    [ 
      "/", Rack::Utils.escape(language.short_name),
      "/", Rack::Utils.escape(self.fullname)
    ].join
  end
end
