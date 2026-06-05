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
