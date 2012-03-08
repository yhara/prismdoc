class SingletonMethodEntry < MethodEntry
  def path(language)
    self.module.path(language) +
      "/" + "." + Rack::Utils.escape(self.name)
  end
end
