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

  def fullname_of(entry_or_name)
    name = case entry_or_name
           when Entry 
             if entry_or_name.library_id != self.id
               raise ArgumentError, "not in me #{self.name} (#{entry_or_name.inspect})"
             end
             entry_or_name.belong_name
           when String 
             entry_or_name
           else
             raise TypeError, "unknown class for fullname_of: #{entry_or_name.inspect}(#{entry_or_name.class})"
           end

    "#{self.name};#{name}"
  end
end
