class Entry < ActiveRecord::Base
  has_many :documents

  validates :name,     presence: true
  validates :fullname, presence: true, uniqueness: true

  # Shortcut to an instance of Entry.
  # Useful in rails console (eg. Entry["Array#map!"])
  def self.[](fullname)
    Entry.find_by_fullname!(fullname)
  end

  def self.builtin_modules
    mods = ModuleEntry.where(library_id: Entry["_builtin"].id).
                       order(:name).to_a
    exception = mods.find{|m| m.name == "Exception"} or raise "Exception not found"
    mods.delete(exception)

    build_tree = ->(parent){
      children = mods.select{|m| m.is_a?(ClassEntry) and m.superclass_id == parent.id}
      mods.replace(mods - children)

      children.inject({}) do |h, c|
        h[c] = build_tree[c]; h
      end
    }
    tree = {exception => build_tree[exception]}

    [mods, tree]
  end

  def self.libraries
    LibraryEntry.includes(:modules).order(:fullname).select{|l|
      not l.name.include?("/") and
      not l.name == "_builtin"
    }.inject({}) do |h, l|
      h[l] = l.modules.sort_by(&:name).inject({}){|h2, m| h2[m] = {}; h2}.merge(
        LibraryEntry.where("name LIKE '#{l.name}/%'").sort_by(&:name).inject({}){|h2, m| h2[m] = {}; h2}
      )
      h
    end
  end
end
