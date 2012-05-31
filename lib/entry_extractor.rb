require 'tsort'
require 'bitclust_helper'
require 'rdoc_helper'
require 'extractor_helper'

module RubyApi
  class RDocEntryExtractor
    include ExtractorHelper

    def initialize(ver_str)
      @version = Version.find_or_create_by_name(name: ver_str)
      @rdoc = RDocHelper.new(@version)
      @missing_superclass = []
    end

    def run
      Entry.transaction do
        lib_entry = make_library_entries
        make_builtin_entries(lib_entry)
      end
    end

    private

    def make_library_entries
      clogger.info("Creating entry _builtin")
      LibraryEntry.create!(fullname: "_builtin", name: "_builtin", version: @version)
    end

    def make_builtin_entries(lib_entry)
      @rdoc.modules.each do |mod_name|
        # TODO: ENV ARGF
        next if %w(ENV ARGF).include?(mod_name)

        mod_entry = make_module_entry(lib_entry, mod_name)
        make_entries_in_module(lib_entry, mod_entry)
      end

      clogger.info "Updating postponed .superclass"
      @missing_superclass.each do |mod_name, super_name|
        clogger.debug "- #{mod_name} < #{super_name}"
        superentry = Entry[lib_entry.fullname_of(super_name)]
        Entry[lib_entry.fullname_of(mod_name)].update_attributes!(superclass: superentry)
      end
    end

    # Returns a ModuleEntry
    def make_module_entry(lib_entry, mod_name)
      raise ArgumentError unless @rdoc.module?(mod_name)
      fullname = lib_entry.fullname_of(mod_name)
      clogger.info("Creating entry #{fullname}")

      if @rdoc.class?(mod_name)
        # Class
        super_name = @rdoc.superclass(mod_name)
        if super_name.nil?
          # BasicObject
          superclass = nil
        else
          superclass = Entry.find_by_fullname(lib_entry.fullname_of(super_name))
          if superclass.nil?
            @missing_superclass.push [mod_name, super_name]
          end
        end
        ClassEntry.create!(fullname: lib_entry.fullname_of(mod_name),
                           name: mod_name,
                           superclass: superclass,
                           library: lib_entry,
                           version: @version)
      else
        # Module
        ModuleEntry.create!(fullname: lib_entry.fullname_of(mod_name),
                            name: mod_name,
                            library: lib_entry,
                            version: @version)
      end
    end

    def make_entries_in_module(lib_entry, mod_entry)
      attrs = {
        module_id: mod_entry.id,
        library_id: lib_entry.id,
        version: @version,
      }
      @rdoc.singleton_methods(mod_entry.name).each do |name|
        fullname = "#{mod_entry.fullname}.#{name}"
        clogger.debug("Creating entry #{fullname}")
        SingletonMethodEntry.create(attrs.merge({name: name, fullname: fullname}))
      end
      @rdoc.instance_methods(mod_entry.name).each do |name|
        fullname = "#{mod_entry.fullname}##{name}"
        clogger.debug("Creating entry #{fullname}")
        InstanceMethodEntry.create(attrs.merge({name: name, fullname: fullname}))
      end
      @rdoc.constants(mod_entry.name).each do |name|
        fullname = "#{mod_entry.fullname}::#{name}"
        clogger.debug("Creating entry #{fullname}")
        ConstantEntry.create(attrs.merge({name: name, fullname: fullname}))
      end
    end
  end

  EntryExtractor = RDocEntryExtractor

  class BitClustEntryExtractor
    include BitClustHelper
    include ExtractorHelper

    def initialize(ver)
      @ver = ver
      @missing_superclass = []
    end

    def run
      make_library_entries
      make_builtin_methods
    end

    def make_library_entries
      libs = db(@ver).libraries.select{|l|
        # TODO: handle sublibraries
        #not l.is_sublibrary #and ["_builtin", "set"].include?(l.name)
        not %w(minitest/spec irb/notifier).include?(l.name) #TODO
      }
      # _builtin should come first
      libs.unshift(libs.delete(libs.find{|l| l.name == "_builtin"}))

      libs.each do |lib|
        name = normalize_library_name(lib.name)
        clogger.debug "creating entry for library #{name}"
        lib_entry = Entry.where(name: name).first
        lib_entry ||= LibraryEntry.create!(fullname: name, name: name, version: @version)
        make_module_entries(lib, lib_entry)
      end

      clogger.info "Setting suspended .superclass"

      @missing_superclass.each do |child, parent|
        clogger.debug "- #{child.name} < #{parent.name}"
        superentry = Entry[fullname_of(parent)]
        Entry[fullname_of(child)].update_attributes!(superclass: superentry)
      end
    end

    # Make entries for classes/modules defined in the library.
    #
    def make_module_entries(library, lib_entry)
      mods = BitClustModules.new(library).tsort
      clogger.debug [library.name, mods.map(&:name)].inspect
      mods.each do |m|
        case m.type
        when :class, :module
          if m.library != library
            clogger.warn "library #{library.name} defines #{fullname_of(m)}; skipping."
            next
          end

          clogger.debug "creating entry for #{m.type} #{fullname_of(m)}"

          if m.type == :module
            ModuleEntry.create!(fullname: fullname_of(m),
                                name: m.name,
                                library: lib_entry,
                                version: @version)
          else
            if s = m.superclass 
              superclass = Entry.find_by_fullname(fullname_of(s))
              @missing_superclass.push [m, s] if superclass.nil?
            else
              superclass = nil
            end

            ClassEntry.create!(fullname: fullname_of(m),
                               name: m.name,
                               superclass: superclass,
                               library: lib_entry,
                               version: @version)
          end
        else
          clogger.warn "skipping #{m.type} #{m.name}"
        end
      end
    end

    def make_builtin_methods
      builtin = db(@ver).libraries.find{|l| l.name == "_builtin"}
      builtin.classes.each do |mod|
        next if mod.type == :object
        make_builtin_methods_of(mod)
      end
    end

    private

    def make_builtin_methods_of(mod)
      lib_entry = LibraryEntry[mod.library.name]
      mod_entry = ModuleEntry["#{lib_entry.name};#{mod.name}"]

      mod.entries.each do |meth|
        # Skip methods defined by another library
        next if meth.library != mod.library

        attrs = {
          name: meth.name,
          module_id: mod_entry.id,
          library_id: lib_entry.id,
          version: @version,
        }
        case meth.typename
        when :singleton_method, :module_function
          attrs[:fullname] = "#{mod_entry.fullname}.#{meth.name}"
          clogger.debug "creating entry for #{attrs[:fullname]}"
          SingletonMethodEntry.create!(attrs)
        when :instance_method
          attrs[:fullname] = "#{mod_entry.fullname}##{meth.name}"
          clogger.debug "creating entry for #{attrs[:fullname]}"
          clogger.debug attrs.inspect
          InstanceMethodEntry.create!(attrs)
        when :constant
          attrs[:fullname] = "#{mod_entry.fullname}::#{meth.name}"
          clogger.debug "creating entry for #{attrs[:fullname]}"
          ConstantEntry.create!(attrs)
        when :special_variable
          # skip
        else
          raise "unknown typename: #{meth.typename}"
        end
      end
    end

    def fullname_of(mod)
      normalize_library_name(mod.library.name) + ";" + mod.name
    end

    # Note: downcasing for English.rb and Win32API.rb
    # We cannot just downcase it because of tkextlib/{ICONS, tkDND, tkHTML}
    def normalize_library_name(name)
      (name[0] =~ /[A-Z]/ ? name.downcase : name)
    end

    # We need to make sure create BasicObject first 
    # because otherwise we can't set Object's superclass.
    #
    # TSort (magically) gives us the ordering.
    class BitClustModules
      include TSort

      def initialize(lib)
        @modules = lib.classes
      end

      def tsort_each_node(&block)
        @modules.each &block
      end

      def tsort_each_child(mod, &block)
        return if mod.nil?
        return if mod.superclass.nil?
        return if not @modules.include?(mod.superclass)

        yield mod.superclass
      end
    end
  end
end
