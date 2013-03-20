class Organization < ActiveRecord::Base
  has_many :teams

  attr_accessible :name, :has_octocats

  scope :has_octocats_scope, lambda { where(:has_octocats => true) }

  def self.has_octocats_class_method
    where(:has_octocats => true)
  end
end
