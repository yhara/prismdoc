require 'rdoc/ri/driver'
Driver = RDoc::RI::Driver

module RubyApi
  class RDocHelper
    def initialize(ver_name)
      @ver_name = ver_name
    end

    def modules
      store.modules
    end

    def module?(mod_name)
      store.modules.include?(mod_name)
    end

    def class?(mod_name)
      mod_name == "Object" or
      mod_name == "BasicObject" or
      store.ancestors.key?(mod_name)
    end

    def superclass(mod_name)
      raise ArgumentError unless class?(mod_name)

      ancestors = store.ancestors[mod_name]
      if ancestors
        ancestors.find{|name| class?(name)}
      else
        nil
      end
    end

    private

    def store
      @store ||= rdoc_driver.stores.find{|store| store.path == rdoc_data_path}
    end

    def rdoc_data_path
      DocumentSource.rdoc_data_path(@ver_name)
    end

    def rdoc_driver
      @driver ||= begin
        options = Driver.process_args(["-d", rdoc_data_path])
        Driver.new(options)
      end
    end
  end
end
