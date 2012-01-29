class Entry < ActiveRecord::Base
  has_many :documents
  belongs_to :entry_type

  validates :name,     presence: true
  validates :fullname, presence: true, uniqueness: true

  def type
    self.entry_type.name
  end

  def self.[](fullname)
    Entry.find_by_fullname(fullname)
  end
end
