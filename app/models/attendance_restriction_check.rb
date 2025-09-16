# frozen_string_literal: true

class AttendanceRestrictionCheckResult
  def initialize(success, error_symbol = nil)
    @success = success
    @error_symbol = error_symbol
  end

  def success?
    @success
  end

  def self.error_result(error_symbol)
    AttendanceRestrictionCheckResult.new(false, error_symbol)
  end

  attr_reader :error_symbol
end

SUCCESS_RESULT = AttendanceRestrictionCheckResult.new(true)

class AttendanceRestrictionCheck
  PAST_SIGNUPS_THRESHOLD = 10.days

  def initialize(user, calendar_event)
    @user = user
    @calendar_event = calendar_event
  end

  def can_create_signup
    return AttendanceRestrictionCheckResult.error_result(:expired_error) unless any_event_ongoing?

    SUCCESS_RESULT
  end

  def can_create_excuse
    return AttendanceRestrictionCheckResult.error_result(:past_calendar_event_error) if calendar_event.past?
    return AttendanceRestrictionCheckResult.error_result(:already_present_error) if attendance.persisted?

    SUCCESS_RESULT
  end

  def can_create_excuse?
    can_create_excuse.success?
  end

  def can_create_signup?
    can_create_signup.success?
  end

  def attendance
    return @attendance unless @attendance.nil?

    attendance = calendar_event.attendances.find_or_initialize_by(user: user)
    attendance.status = Attendance::STATUS_UNKNOWN if attendance.new_record?
    @attendance = attendance
  end

  private

  def any_event_ongoing?
    calendar_event.ongoing? ||
      (CalendarEvent.ongoing.any? && calendar_event.past? && calendar_event.starts_at > PAST_SIGNUPS_THRESHOLD.ago)
  end

  attr_reader :user, :calendar_event
end
