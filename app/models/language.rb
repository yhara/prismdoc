class Language < ActiveRecord::Base
  has_many :documents

  validates :english_name, presense: true, uniqueness: true
  validates :native_name,  presense: true, uniqueness: true

  def self.[](name)
    EntryType.find_by_english_name(name)
  end
end
