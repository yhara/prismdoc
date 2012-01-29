class Language < ActiveRecord::Base
  has_many :documents

  validates :english_name, presence: true, uniqueness: true
  validates :native_name,  presence: true, uniqueness: true

  def self.[](name)
    Language.find_by_english_name(name)
  end
end
