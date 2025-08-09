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
end
