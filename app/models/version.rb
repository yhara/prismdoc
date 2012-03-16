class Version < ActiveRecord::Base
  has_many :documents

  validates :name,   presence: true, uniqueness: true

  def self.default
    Language["English"]
  end

  def self.[](name)
    Version.find_by_name(name)
  end
end
