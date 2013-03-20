class Team < ActiveRecord::Base
  belongs_to :organization
  attr_accessible :name

  def self.using_octocats_scope
    where(:organization_id => Organization.has_octocats_scope.select(:id))
  end

  def self.using_octocats_class_method
    where(:organization_id => Organization.has_octocats_class_method.select(:id))
  end
end
