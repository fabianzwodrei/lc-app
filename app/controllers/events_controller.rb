class EventsController < ApplicationController

  load_and_authorize_resource

  def calendar
    @date = params[:date] ? Date.parse(params[:date]) : Date.today

    starting = @date.beginning_of_month.beginning_of_week(:monday)
    ending = @date.end_of_month.end_of_week(:monday)

    @events = Event.grouped_by_date_from_now starting, ending
  end

  def export
    @events = make_calendar_items :exportable_time
  end

  def index
    @past = true if params[:past] == 'true'
    @events = make_calendar_items :viewable_time, @past
  end

  def show
    @public_mode = true
  end

  def update
    if @event.update(event_params)
        redirect_to edit_event_path(@event), notice: 'Termin wurde erfolgreich aktualisiert.'
    else
      render action: 'edit'
    end
  end

  def new
    @event = Event.new
  end

  def create
    @event.archive = false
    if @event.save
      if request.format == :json
        render :json => @event
      else
        redirect_to calendar_events_path(params:{date:@event.dates.first.to_date}), notice: 'Termin wurde gespeichert.'
      end
    else
      render action: 'new'
    end
  end

  def email
      @event.attendances.permitted.each do |attendance|
        MailWorker.perform_async(
          JSON.generate( m_id: attendance.member_id, email_subject: "RLCC Termin: - " + params[:email_subject], email_body: params[:email_body] )
        )
      end
      head :ok, content_type: "text/html"
  end

  def attend
    prefix = @event.permission_required ?  'Bewerbung' : 'Teilnahme'
    notice = @event.attendances.create({member_id: current_member.id, permitted: !@event.permission_required}) ?
        "#{prefix} wurde erfolgreich gespeichert." :
        'Fehler: Teilnahme konnte nicht gespeichert werden.'
    redirect_back notice: notice, fallback_location: root_url
  end

  def unattend
    prefix = @event.permission_required ?  'Bewerbung' : 'Teilnahme'

    attendance = @event.attendances.where('member_id' => current_member.id).first
    attendance.destroy unless attendance.blank?
    redirect_back(
        notice: "#{prefix} wurde abgesagt.",
        fallback_location: root_url
    )
  end

  def add_member
    add_member_to_event(@event, Member.find(params[:member_id]))
  end

  def remove_member
    remove_member_from_event(@event,(Member.find params[:member_id]))
  end

  protected
    def add_member_to_event(event,member)
      if event.members.include? member
        return redirect_to send("edit_#{event.class.to_s.downcase}_path"), notice: "Fehler. Das Mitglied ist entweder bereits zugewiesen oder unbekannt."
      end

      event.members.push member
      at = Attendance.where(member_id: member.id, event_id: event.id)
      at.update(permitted:true)

      redirect_to send("edit_#{event.class.to_s.downcase}_path"), notice: "Mitglied wurde erfolgreich hinzugefügt."
    end

    def remove_member_from_event(event,member)
      if event.members.include? member
        at = Attendance.where(member_id: member.id,event_id: event.id)
        if event.class == Course and at.first.passed # for we know there is only one attendance. but this is brittle
          return redirect_to send("edit_#{event.class.to_s.downcase}_path"), notice: "Die Kursteilnahme wird nicht aufgehoben, da der Kurserfolg schon bescheinigt wurde." # should not happen since there shouldn't be a button then
        end
        at.destroy_all
        return redirect_to send("edit_#{event.class.to_s.downcase}_path"), notice: "Die Kursteilnahme für das Mitglied wurde aufgehoben."
      end

      redirect_to send("edit_#{event.class.to_s.downcase}_path"), notice: "Ein Fehler ist aufgetreten."
    end


    def load_events(type,department_id=nil)
      if department_id != nil
        events = type.by_department(department_id)
      else
        events = type
      end

      from = nil
      from = params[:from].to_i if params[:from]
      if from
        count = events.archived.count
        events = events.archived.offset(from).limit(Rails.configuration.x.page_items)
      else
        count = nil
        events = events.active
      end
      return events, from, count
    end

  private

    def viewable_time(date)
      date.strftime('%d.%m.%Y - %H:%M').to_s
    end

    def exportable_time(date)
      date.strftime('%Y%m%dT%H%M%S')
    end

    def make_calendar_items(datefun, inverse=false)
      items = []
      make_courses_items items
      make_consultations_items items
      make_events_items items
      apply_datefun(_sort(clear(items,inverse),inverse),datefun)
    end

    def make_courses_items(cal_items)
      current_member.courses.each do |c|
        next unless is_permitted c and c.dates
        for date in c.dates
          cal_items.push add_calendar_item(c.id, date, c.title, 'Kurstermin', c.where)
        end
      end
    end

    def make_consultations_items(cal_items)
      current_member.consultations.each do |c|
        cal_items.push add_calendar_item(c.id, c.dates[0], c.title, 'Sprechstunde', c.where) if is_permitted c
      end
    end

    def make_events_items(cal_items)
      current_member.departments.each do |d|
        department_events = Event.where(department_id:d)
        next unless department_events
        for dm in department_events
          for date in dm.dates
            cal_items.push add_calendar_item(dm.id, date, dm.title, 'Ressort-Termin', dm.where)
          end
        end
      end

      # general events or events of other departments the member could have joined 
      current_member.events.each do |e|
        next unless is_permitted e and e.dates
        
        # filter duplicates
        same_events = cal_items.select { |ee| ee[:id] == e.id }
        next if same_events.count > 0

        for date in e.dates
          cal_items.push add_calendar_item(e.id, date, e.title, 'Termin', e.where)
        end
      end
    end



    def deps_ids
      deps_ids = []
      current_member.departments.each do |d|
        deps_ids.push d
      end
      deps_ids
    end

    # makes a calendar item for a event
    # even if there is more than one date,
    # only the first is taken. however, this should not happen at all,
    # since only the first date is taken during create and update.
    def add_item_for_event(event_event, cal_items)
        cal_items.push add_calendar_item(event_event.id, event_event.dates[0], event_event.title, "Arbeitstreffen Ressort #{DEPARTMENT_TITLES[event_event.department_id]}", event_event.where)
      
    end


    def _sort(events,inverse = false)
      if not inverse
        events.sort_by {|vn| vn[:date]}
      else
        events.sort {|vn1, vn2| vn2[:date] <=> vn1[:date]}
      end
    end

    def apply_datefun(events,datefun)
      for event in events
        event[:date] = self.method(datefun).call(event[:date])
      end
      events
    end

    def clear(events,inverse)
      evts = []
      for event in events
        if !inverse && event[:date] > Date.today
          evts.push event
        elsif inverse && event[:date] < Date.today
          evts.push event
        end
      end
      evts
    end

    def is_permitted(event)
      if event.permission_required
        for at in event.attendances
          if (at.member_id == current_member.id) && (!at.permitted)
            return false
          end
        end
      end
      true
    end

    def add_calendar_item(id, date, title, type, place, info=nil)
      {
          id: id, # the id field is used to detect duplicates of events
          # it is taken from the event, which works because we know
          # there is exactly one calendar item per event event.
          type: type,
          title: title,
          date: date,
          place: place,
          info: info
      }
    end

    def event_params
      params.require(:event).permit(
          :permission_required, :title,:where,:description,:archive, :department_id, :dates_string)
    end
end