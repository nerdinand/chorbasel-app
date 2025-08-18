# frozen_string_literal: true

class AttendanceRestrictionCheckResult
  def initialize(success, error_symbol = nil)
    @success = success
    @error_symbol = error_symbol
  end

  def success?
    @success
  end

  attr_reader :error_symbol
end

SUCCESS_RESULT = AttendanceRestrictionCheckResult.new(true)

class AttendanceRestrictionCheck
  def initialize(user, calendar_event)
    @user = user
    @calendar_event = calendar_event
  end

  def can_create_signup
    return AttendanceRestrictionCheckResult.new(false, :expired_error) unless calendar_event.ongoing?

    SUCCESS_RESULT
  end

  private

  attr_reader :user, :calendar_event
end
