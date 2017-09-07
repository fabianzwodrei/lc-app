class RenameAllMeetingTypesToEvent < ActiveRecord::Migration[5.0]
  def change
  	execute "UPDATE events e SET type = ''  WHERE  e.type = 'Meeting';"
  end
end
