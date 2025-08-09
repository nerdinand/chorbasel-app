# frozen_string_literal: true

class AttendanceTallyTable
  COLORS = {
    Register::Singer::REGISTER_SOPRANO => '#b0e09a',
    Register::Singer::REGISTER_ALTO => '#e09e9a',
    Register::Singer::REGISTER_TENOR => '#fcfd9d',
    Register::Singer::REGISTER_BASS => '#b3a3fb'
  }.freeze

  def initialize(calendar_events)
    @calendar_events = calendar_events

    @register_counts = calendar_events.index_with do |ce|
      User.user_status_at_time(UserStatus::STATUS_ACTIVE, ce.starts_at).group(:canonical_register).count
    end

    @tallies = calendar_events.index_with do |ce|
      ce.attendances.joins(:user).group('users.canonical_register').count
    end
  end

  attr_reader :calendar_events

  def registers
    Register::Singer::CANONICAL_REGISTERS
  end

  def register_percentages(calendar_event)
    registers.index_with do |r|
      100 * @tallies[calendar_event][r].to_f / (@register_counts[calendar_event][r] || 0)
    end
  end

  def total_percentage(calendar_event)
    100 * @tallies[calendar_event].sum(&:last).to_f / @register_counts[calendar_event].sum(&:last)
  end

  def chart_data
    registers.map do |r|
      { name: r, color: COLORS[r], data: calendar_events.map { |ce| [ce.date, register_percentages(ce)[r].round(2)] } }
    end
  end
end
