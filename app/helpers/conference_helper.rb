# frozen_string_literal: true

module ConferenceHelper
  # Return true if only call_for_papers or call_for_tracks or call_for_booths is open
  def one_call_open(*calls)
    calls.one? { |call| call.try(:open?) }
  end
  # Return true if exactly two of those calls are open: call_for_papers , call_for_tracks , call_for_booths

  def two_calls_open(*calls)
    calls.count { |call| call.try(:open?) } == 2
  end

  # URL for sponsorship emails
  def sponsorship_mailto(conference)
    [
      'mailto:',
      conference.contact.sponsor_email,
      '?subject=',
      url_encode(conference.short_title),
      '%20Sponsorship'
    ].join
  end

  def short_ticket_description(ticket)
    return unless ticket.description

    markdown(ticket.description.split("\n").first&.strip)
  end

  def conference_color(conference)
    conference.color.presence || Rails.configuration.conference[:default_color]
  end

  # adds events to icalendar for proposals in a conference
  def icalendar_proposals(calendar, proposals, conference)
    proposals.each do |proposal|
      calendar.event do |e|
        e.dtstart = proposal.time
        e.dtend = proposal.time + (proposal.event_type.length * 60)
        e.duration = "PT#{proposal.event_type.length}M"
        e.created = proposal.created_at
        e.last_modified = proposal.updated_at
        e.summary = proposal.title
        e.description = proposal.abstract
        e.uid = proposal.guid
        e.url = conference_program_proposal_url(conference.short_title, proposal.id)
        v = conference.venue
        if v
          e.geo = v.latitude, v.longitude if v.latitude && v.longitude
          location = ''
          location += "#{proposal.room.name} - " if proposal.room.name
          location += " - #{v.street}, " if v.street
          location += "#{v.postalcode} #{v.city}, " if v.postalcode && v.city
          location += "#{v.country_name}, " if v.country_name
          e.location = location
        end
        e.categories = conference.title
        e.categories << "Difficulty: #{proposal.difficulty_level.title}" if proposal.difficulty_level.present?
        e.categories << "Track: #{proposal.track.name}" if proposal.track.present?
      end
    end
    calendar
  end

  def get_happening_now_events_schedules(conference)
    events_schedules = filter_events_schedules(conference, :happening_now?)
    events_schedules ||= []
    events_schedules
  end

  def get_happening_next_events_schedules(conference)
    events_schedules = filter_events_schedules(conference, :happening_later?)

    return [] if events_schedules.empty?

    # events_schedules have been sorted by start_time in selected_event_schedules
    happening_next_time = events_schedules[0].start_time
    events_schedules.select { |s| s.start_time == happening_next_time }
  end

  def load_happening_now
    events_schedules_list = get_happening_now_events_schedules(@conference)
    @is_happening_next = false
    if events_schedules_list.empty?
      events_schedules_list = get_happening_next_events_schedules(@conference)
      @is_happening_next = true
    end
    @events_schedules_limit = Rails.configuration.conference[:events_per_page]
    @events_schedules_length = events_schedules_list.length
    @pagy, @events_schedules = pagy_array(events_schedules_list,
                                          items:      @events_schedules_limit,
                                          link_extra: 'data-remote="true"')
  end

  private

  # TODO: Move this to using the cached method on program/schedule
  def filter_events_schedules(conference, filter)
    conference.program.selected_event_schedules(
      includes: [:event, :room, { event:
                                         %i[event_type speakers speaker_event_users track program] }]
    ).select(&filter)
  end
end
