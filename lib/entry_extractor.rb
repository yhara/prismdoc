require 'logger'
require 'bitclust_helper'

module RubyApi
  class EntryExtractor
    include BitClustHelper

    def run
      make_library_entries
    end

    def make_library_entries
      libs = db.libraries.select{|l|
        # TODO: handle sublibraries
        not l.is_sublibrary and ["_builtin", "set"].include?(l.name)
      }
      # Make sure _builtin comes first
      libs.unshift(libs.delete(libs.find{|l| l.name == "_builtin"}))

      libs.each do |lib|
        name = lib.name
        logger.debug "creating entry for library #{name}"
        lib_entry = Entry.create!(fullname: name, name: name, kind: "library")
        make_module_entries(lib, lib_entry)
      end
    end

    # Make entries for classes/modules defined in the library.
    #
    # To set the superclasses properly, we need to make a
    # inheritance tree.
    def make_module_entries(library, lib_entry)
      tree = Hash.new{|h, k| h[k] = {} }
      root, rest = library.classes.partition{|m|
        # This is true when m is
        #   * a module
        #   * BasicObject (Ruby 1.9), Object (Ruby 1.8)
        #   * object ::ARGF
        #   * object ::ENV
        m.superclass.nil?
      }

      # Construct tree by inheritance
      make_node = ->(m){
        Hash[*rest.select{|c| c.superclass == m}.
                   map{|c| [c, make_node[c]]}.flatten(1)]
      }
      tree = Hash[*root.map{|m| [m, make_node[m]]}.flatten(1)]

      # Traverse the tree from the top to the bottom
      walk_tree tree do |m, children|
        case m.type
        when :class, :module
          logger.debug "creating entry for #{m.type} #{m.name}"
          if m.superclass
            superclass = Entry[m.superclass.name]
          else
            superclass = nil
          end
          Entry.create!(fullname: m.name, name: m.name,
                        superclass: superclass,
                        kind: m.type.to_s,
                        library: lib_entry)
        else
          logger.info "skipping #{m.type} #{m.name}"
        end
      end
    end

    private

    def walk_tree(tree, &block)
      tree.each do |k, v|
        yield k, v
        walk_tree(v, &block)
      end
    end

    def logger
      Logger.new($STDOUT)
    end
  end
end
