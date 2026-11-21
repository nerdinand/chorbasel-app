# frozen_string_literal: true

class MeasureMarkersController < ApplicationController
  CSV_HEADERS = %w[time measure].freeze

  def show
    score = Score.find_by(song_id: params[:song_id])
    return empty_csv_response if score.nil?

    score = authorize score

    csv_response(score.measure_markers)
  end

  private

  def empty_csv_response
    csv_response(CSV_HEADERS.join(','))
  end

  def csv_response(content)
    respond_to do |format|
      format.csv do
        render csv: content
      end
    end
  end
end
