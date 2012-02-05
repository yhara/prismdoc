class Language < ActiveRecord::Base
  has_many :documents

  validates :short_name,   presence: true, uniqueness: true
  validates :english_name, presence: true, uniqueness: true
  validates :native_name,  presence: true, uniqueness: true

  def self.default
    Language["English"]
  end

  def self.[](english_name)
    Language.find_by_english_name!(english_name)
  end

  def self.from_short_name(short_name)
    Language.find_by_short_name!(short_name)
  end
end
