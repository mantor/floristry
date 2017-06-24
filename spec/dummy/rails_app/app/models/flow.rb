class Flow < ActiveRecord::Base
  validates :name, presence: true
  validates :definition, presence: true
end
