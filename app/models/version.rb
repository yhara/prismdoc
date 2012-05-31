class Version < ActiveRecord::Base
  has_many :entries
  has_many :documents

  validates :name,   presence: true, uniqueness: true

  default_scope :order => "name DESC"

  def self.latest
    Version.first
  end

  def self.[](name)
    Version.find_by_name(name)
  end
end
