class Invitation < ActiveRecord::Base
	belongs_to :project
	belongs_to :member
end