# frozen_string_literal: true

module AttendancesHelper
  STATUS_ICON_MAP = {
    Attendance::STATUS_ATTENDED => :check,
    Attendance::STATUS_EXCUSED => :square_letter_e,
    Attendance::STATUS_EXCUSE_REQUESTED => :letter_e,
    Attendance::STATUS_UNKNOWN => :question_mark
  }.freeze

  def attendances_status_options
    Attendance::STATUSES.map { |r| [t("activerecord.attributes.attendance.enums.status.#{r}"), r] }
  end

  def icon_for_status(status)
    tabler_icon(STATUS_ICON_MAP[status],
                classes: ['status-icon', "attendance-status-icon-#{status}"])
  end

  def attendance_action_or_status(calendar_event)
    attendance_check = AttendanceRestrictionCheck.new(current_user, calendar_event)
    attendance = attendance_check.attendance

    html = []
    html << icon_for_status(attendance.status)
    html << t("dashboard.show.attendance_status.#{attendance.status}")

    html << '<br>'

    if attendance_check.can_create_signup?
      html << (button_to t('dashboard.show.calendar_events.attendance.submit'),
                         calendar_event_attendance_attendance_path(calendar_event), method: :post, class: 'btn btn-secondary')
    elsif attendance_check.can_create_excuse?
      html << (link_to t('dashboard.show.calendar_events.attendance.new'),
                       new_calendar_event_attendance_excuse_path(calendar_event),
                       class: 'btn btn-primary')
    end
    html.join.html_safe
  end

  def attendance_action_symbol(calendar_event)
    icon_for_status(AttendanceRestrictionCheck.new(current_user, calendar_event).attendance.status)
  end
end
