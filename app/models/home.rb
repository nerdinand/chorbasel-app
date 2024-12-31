# frozen_string_literal: true

class Home
  def initialize(calendar_events, attendances, upcoming_birthdays, info, attendance_table)
    @calendar_events = calendar_events
    @attendances = attendances
    @upcoming_birthdays = upcoming_birthdays
    @info = info
    @attendance_table = attendance_table
  end

  attr_reader :calendar_events, :attendances, :upcoming_birthdays, :info, :attendance_table

  def info?
    info.present?
  end

  def attendances?
    attendances.any?
  end
end
