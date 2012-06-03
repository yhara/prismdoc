class Language < ActiveRecord::Base
  has_many :documents, dependent: :delete_all
  has_many :paragraphs, dependent: :delete_all

  validates :short_name,   presence: true, uniqueness: true
  validates :english_name, presence: true, uniqueness: true
  validates :native_name,  presence: true, uniqueness: true

  def self.default
    Language["English"]
  end

  def self.[](name)
    Language.find_by_short_name(name) or
    Language.find_by_english_name(name) or
    Language.find_by_native_name!(name)
  end

  def self.from_short_name(short_name)
    Language.find_by_short_name!(short_name)
  end
end
