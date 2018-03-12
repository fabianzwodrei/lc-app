module EventsHelper
  def print_dates dates, join_by: ", "
  	return "" unless dates
    raw dates.map{|d| l d }.join(join_by)
  end

  def print_course_type course
  	raw '<b>' + t('course.categories.'+course.category1 + '.name') + '</b> / ' + t('course.categories.' + course.category1 + '.sub_categories.' + course.category2)
  end

  def print_qualification_validity course
  	if course.qualification_date && (course.qualification_date+365) > Date.today-1
     return "gültig bis " + (course.qualification_date+365).strftime('%d.%m.%Y')
    end
    return ""
  end
end
