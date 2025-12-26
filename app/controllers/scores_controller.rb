# frozen_string_literal: true

class ScoresController < ApplicationController
  def new
    @score = authorize Score.new(song_id: params[:song_id])
  end

  def edit
    @score = authorize Score.find_by(song_id: params[:song_id])
  end

  def create
    @score = authorize Score.new(score_params)

    if @score.save
      flash.notice = t('.success')
      redirect_to song_path(@score.song)
    else
      flash.alert = t('.error')
      render :new, status: :unprocessable_content
    end
  end

  def update
    @score = authorize Score.find_by(song_id: params[:song_id])

    if @score.update(score_params)
      flash.notice = t('.success')
      redirect_to song_path(@score.song)
    else
      flash.alert = t('.error')
      render :edit, status: :unprocessable_content
    end
  end

  private

  def score_params
    params.expect(score: %i[song_id file metadata])
  end
end
