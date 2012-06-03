require 'rdoc/ri/driver'
Driver = RDoc::RI::Driver

module RubyApi
  class RDocHelper
    def initialize(ver)
      @ver = ver
    end

    # Entry

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

    # Document

    def module_doc(mod_name)
      rescue_enoent do
        to_rdoc store.load_class(mod_name).comment
      end
    end

    def singleton_method_doc(mod_name, meth_name)
      rescue_enoent do
        to_rdoc store.load_method(mod_name, meth_name).comment
      end
    end
    alias constant_doc singleton_method_doc

    def instance_method_doc(mod_name, meth_name)
      rescue_enoent do
        to_rdoc store.load_method(mod_name, "#"+meth_name).comment
      end
    end

    # HTML

    def html(rdoc_txt)
      RDoc::Markup::ToHtml.new.convert(rdoc_txt)
    end

    private

    def rescue_enoent(&block)
      return block.call
    rescue Errno::ENOENT
      return nil
    end

    def to_rdoc(doc)
      doc.accept(RDoc::Markup::ToRdoc.new)
    end

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
