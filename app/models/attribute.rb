class Attribute < ActiveRecord::Base
  def self.find_or_create_by_name(name)
    where(:name => name).first || create(:name => name)
  end
  
  def to_s
    name
  end
end
