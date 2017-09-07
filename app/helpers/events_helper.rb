module EventsHelper
  def print_dates dates, join_by: ", "
  	return "" unless dates
    raw dates.map{|d| l d }.join(join_by)
  end
end
