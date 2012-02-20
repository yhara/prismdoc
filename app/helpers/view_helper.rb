require 'rack/utils'

module ViewHelper
  def show_library_path(which, language=@language)
    fullname = (which.is_a?(Entry) ? which.fullname : which)
    [ 
      "/", Rack::Utils.escape(language.short_name),
      "/", Rack::Utils.escape(fullname)
    ].join
  end

  def show_module_path(which, language=@language)
    fullname = (which.is_a?(Entry) ? which.fullname : which)
    [ 
      "/", Rack::Utils.escape(language.short_name),
      "/", Rack::Utils.escape(fullname)
    ].join
  end

  def show_method_path(entry, language=@language)
    prefix = (entry.type == "class_method" ? "." : "")
    [ 
      "/", Rack::Utils.escape(language.short_name),
      "/", Rack::Utils.escape(entry.class_name),
      "/", prefix, Rack::Utils.escape(entry.method_name)
    ].join
  end
end
