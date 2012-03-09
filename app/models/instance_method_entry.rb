class InstanceMethodEntry < MethodEntry
  def belong_name
    self.module.name + "#" + self.name
  end

  def path(language)
    self.module.path(language) +
      "/" + Rack::Utils.escape(self.name)
  end
end
