class Entry < ActiveRecord::Base
  has_many :documents
  belongs_to :entry_type

  validates :name,     presense: true
  validates :fullname, presense: true, uniqueness: true
end
