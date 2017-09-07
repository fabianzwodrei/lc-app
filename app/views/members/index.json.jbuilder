json.array! @members do |member|
	json.id member.id
	json.name member.full_name
end