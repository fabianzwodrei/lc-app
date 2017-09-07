json.array! @member do |member|
  json.id member.id
  json.name member.first_name + " " + member.last_name
end