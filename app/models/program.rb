# frozen_string_literal: true

class Program < ApplicationRecord
  belongs_to :calendar_event
  belongs_to :song_list
end
