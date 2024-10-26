# frozen_string_literal: true

module AttendancesHelper
  def attendances_status_options
    Attendance::STATUSES.map { |r| [t("activerecord.attributes.attendance.enums.status.#{r}"), r] }
  end
end
