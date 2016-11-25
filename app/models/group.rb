class Group < ApplicationRecord
  has_and_belongs_to_many :members, source: :member_id, class_name: 'User'

  # has_many :members, through: :user_group, source: :User # may be wrong
	validates :name, :location, { presence: :true }
end
