json.array! @people do |person|
	json.id person.id
	json.name person.first_name + " " + person.last_name
end