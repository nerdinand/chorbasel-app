class Home
  def initialize(calendar_events, attendances, upcoming_birthdays, info)
    @calendar_events = calendar_events
    @attendances = attendances
    @upcoming_birthdays = upcoming_birthdays
    @info = info
  end

  attr_reader :calendar_events, :attendances, :upcoming_birthdays, :info

  def has_info?
    info.present?
  end

  def has_attendances?
    attendances.any?
  end
end
