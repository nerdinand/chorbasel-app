# frozen_string_literal: true

module AttendancesHelper
  def attendances_status_options
    Attendance::STATUSES.map { |r| [t("activerecord.attributes.attendance.enums.status.#{r}"), r] }
  end

  def icon_for_status(status)
    label = t("activerecord.attributes.attendance.enums.status.#{status}")
    tag.span(class: ['status-square', "status-square-#{status.to_s.dasherize}"],
             title: label, role: 'img', aria: { label: })
  end

  def attendance_action_symbol(calendar_event)
    icon_for_status(AttendanceRestrictionCheck.new(current_user, calendar_event).attendance.status)
  end
end
