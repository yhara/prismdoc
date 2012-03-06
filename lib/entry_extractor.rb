require 'tsort'
require 'logger'
require 'bitclust_helper'

module RubyApi
  class EntryExtractor
    include BitClustHelper

    def initialize
      @missing_superclass = []
    end

    def run
      make_library_entries
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
        # Note: downcasing for English.rb and Win32API.rb
        name = lib.name.downcase
        logger.debug "creating entry for library #{name}"
        lib_entry = Entry.create!(fullname: name, name: name, kind: "library")
        make_module_entries(lib, lib_entry)
      end

      logger.info "Setting suspended .superclass"

      @missing_superclass.each do |child, parent|
        logger.debug "- #{child.name} < #{parent.name}"
        superentry = Entry[fullname_of(parent)]
        Entry[fullname_of(child)].update_attributes!(superclass: superentry)
      end
    end

    # Make entries for classes/modules defined in the library.
    #
    def make_module_entries(library, lib_entry)
      mods = BitClustModules.new(library).tsort
      logger.debug [library.name, mods.map(&:name)].inspect
      mods.each do |m|
        case m.type
        when :class, :module
          if m.library != library
            logger.warn "library #{library.name} defines #{fullname_of(m)}; skipping."
            next
          end

          logger.debug "creating entry for #{m.type} #{fullname_of(m)}"

          if s = m.superclass 
            superclass = Entry.find_by_fullname(fullname_of(s))
            @missing_superclass.push [m, s] if superclass.nil?
          else
            superclass = nil
          end

          Entry.create!(fullname: fullname_of(m),
                        name: m.name,
                        superclass: superclass,
                        kind: m.type.to_s,
                        library: lib_entry)
        else
          logger.warn "skipping #{m.type} #{m.name}"
        end
      end
    end

    private

    def fullname_of(mod)
      mod.library.name.downcase + ";" + mod.name
    end

    def logger
      Logger.new($stdout).tap{|l| l.level = Logger::INFO}
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
