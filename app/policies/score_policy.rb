# frozen_string_literal: true

class ScorePolicy < SongPolicy
  def initialize(user, score)
    super(user, score.song)
  end
end
