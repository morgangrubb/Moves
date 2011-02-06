class MoveBeat < ActiveRecord::Base
  belongs_to :move
  
  validates_presence_of :beat, :description
end
