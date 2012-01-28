class EntryType < ActiveRecord::Base
  has_many :entries

  validates :name, presense: true, uniqueness: true

  def self.[](name)
    EntryType.find_by_name(name)
  end
end
