# frozen_string_literal: true

module SongListsHelper
  def song_list_status_options
    # i18n-tasks-use t('activerecord.attributes.song_list.enums.status')
    SongList.statuses.values.map { |r| [t("activerecord.attributes.song_list.enums.status.#{r}"), r] }
  end

  def song_list_calendar_event_options
    CalendarEvent.future.map { |ce| [ce.date_and_summary, ce.id] }
  end
end
