# frozen_string_literal: true

module SongListsHelper
  def song_list_status_options
    SongList.statuses.values.map { |r| [t("activerecord.attributes.song_list.enums.status.#{r}"), r] }
  end

  def song_list_calendar_event_options
    CalendarEvent.future.map { |ce| ["#{ce.full_date} #{ce.summary}", ce.id] }
  end
end
