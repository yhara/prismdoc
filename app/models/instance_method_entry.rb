class InstanceMethodEntry < MethodEntry
  def belong_name
    self.module.name + "#" + self.name
  end

  def path(language, version)
    self.module.path(language, version) +
      "/" + Rack::Utils.escape(self.name)
  end
end
