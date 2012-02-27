require 'logger'

module RubyApi
  class EntryExtractor
    def run
      make_library_entries
      make_module_entries
    end

    def make_library_entries
      libs = db.libraries.select{|lib|
        not lib.name == "_builtin" and
        not lib.is_sublibrary #TODO
      }
      libs.each do |lib|
        name = lib.name
        logger.debug "creating entry for library #{name}"
        Entry.create!(fullname: name, name: name, kind: "library")
      end
    end

    def make_module_entries
      builtin = db.libraries.find{|l| l.name == "_builtin"}
      tree = Hash.new{|h, k| h[k] = {} }
      root, rest = builtin.classes.partition{|m| m.superclass.nil?}

      make_node = ->(m){
        Hash[*rest.select{|c| c.superclass == m}.
                   map{|c| [c, make_node[c]]}.flatten(1)]
      }
      tree = Hash[*root.map{|m| [m, make_node[m]]}.flatten(1)]

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
                        kind: m.type.to_s)
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

    def db
      @db ||= begin
        dblocation = URI.parse("file://#{DocumentSource.bitclust_db}")
        BitClust::MethodDatabase.connect(dblocation)
      end
    end

    def logger
      Logger.new($stdout)
    end
  end
end
