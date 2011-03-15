class MoveBeat < ActiveRecord::Base
  belongs_to :move
  
  validates_presence_of :beat, :description

  named_scope :ordered, :order => 'position ASC'

  def valid_utf8?
    beat.force_encoding('UTF-8').valid_encoding? && description.force_encoding('UTF-8').valid_encoding?
  end
  
end
