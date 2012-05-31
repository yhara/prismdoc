require 'rdoc/ri/driver'
Driver = RDoc::RI::Driver

module RubyApi
  class RDocHelper
    def initialize(ver)
      @ver= ver
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

    def singleton_methods(mod_name)
      store.class_methods[mod_name] or []
    end

    def instance_methods(mod_name)
      store.instance_methods[mod_name] or []
    end

    def constants(mod_name)
      store.load_class(mod_name).constants.map(&:name)
    end

    private

    def store
      @store ||= rdoc_driver.stores.find{|store| store.path == rdoc_data_path}
    end

    def rdoc_data_path
      DocumentSource.rdoc_data_path(@ver.name)
    end

    def rdoc_driver
      @driver ||= begin
        options = Driver.process_args(["-d", rdoc_data_path])
        Driver.new(options)
      end
    end
  end
end
