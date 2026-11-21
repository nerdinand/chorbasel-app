# frozen_string_literal: true

class ScorePolicy < SongPolicy
  def initialize(user, score)
    super(user, score.song)
  end

  def segment_markers?
    show?
  end

  def measure_markers?
    show?
  end
end
