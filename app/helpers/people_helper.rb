module PeopleHelper
  def set_client_attrs(p)
    if p[:client_attributes]
      p[:client_attributes][:role] = 'client'
      p[:client_attributes][:department_id] = 0
    end
    p
  end

  def permitted_client_attrs()
    [:email,:first_name,:last_name,:phone,:languages,:department_id,:role,:public,:comment,:country_of_origin,:date_of_birth,:gender] 
  end
end
