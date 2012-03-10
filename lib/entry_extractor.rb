require 'tsort'
require 'bitclust_helper'
require 'extractor_helper'

module RubyApi
  class EntryExtractor
    include BitClustHelper
    include ExtractorHelper

    def initialize
      @missing_superclass = []
    end

    def run
      make_library_entries
      make_builtin_methods
    end

    def make_library_entries
      libs = db.libraries.select{|l|
        # TODO: handle sublibraries
        #not l.is_sublibrary #and ["_builtin", "set"].include?(l.name)
        not %w(minitest/spec).include?(l.name) #TODO
      }
      # _builtin should come first
      libs.unshift(libs.delete(libs.find{|l| l.name == "_builtin"}))

      libs.each do |lib|
        name = normalize_library_name(lib.name)
        tlogger.debug "creating entry for library #{name}"
        Entry
        lib_entry = LibraryEntry.create!(fullname: name, name: name)
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
                                library: lib_entry)
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
                               library: lib_entry)
          end
        else
          clogger.warn "skipping #{m.type} #{m.name}"
        end
      end
    end

    def make_builtin_methods
      builtin = db.libraries.find{|l| l.name == "_builtin"}
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
        }
        case meth.typename
        when :singleton_method, :module_function
          attrs[:fullname] = "#{mod_entry.fullname}.#{meth.name}"
          clogger.debug "creating entry for #{attrs[:fullname]}"
          SingletonMethodEntry.create(attrs)
        when :instance_method
          attrs[:fullname] = "#{mod_entry.fullname}##{meth.name}"
          clogger.debug "creating entry for #{attrs[:fullname]}"
          clogger.debug attrs.inspect
          InstanceMethodEntry.create(attrs)
        when :constant
          attrs[:fullname] = "#{mod_entry.fullname}::#{meth.name}"
          clogger.debug "creating entry for #{attrs[:fullname]}"
          ConstantEntry.create(attrs)
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
