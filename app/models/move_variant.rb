class MoveVariant < ActiveRecord::Base
  belongs_to :base, :class_name => "Move"
  belongs_to :variant, :class_name => "Move"
end
