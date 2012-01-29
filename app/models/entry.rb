class Entry < ActiveRecord::Base
  has_many :documents
  belongs_to :entry_type

  validates :name,     presence: true
  validates :fullname, presence: true, uniqueness: true
end
