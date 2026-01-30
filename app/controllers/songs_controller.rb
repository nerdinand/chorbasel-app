# frozen_string_literal: true

class SongsController < ApplicationController
  def index
    @songs = authorize Song.order(:title)
  end

  def show
    @song = authorize Song.includes(:song_media).find(params[:id])
  end

  def new
    @song = authorize Song.new(
      registers: Register::Song::DEFAULT_REGISTERS
    )
  end

  def edit
    @song = authorize Song.find(params[:id])
  end

  def create
    @song = authorize Song.new(song_params)

    if @song.save
      flash.notice = t('.success')
      redirect_to songs_path
    else
      flash.alert = t('.error')
      render :new, status: :unprocessable_content
    end
  end

  def update
    @song = authorize Song.find(params[:id])

    if @song.update(song_params)
      flash.notice = t('.success')
      redirect_to songs_path
    else
      flash.alert = t('.error')
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    song = authorize Song.find(params[:id])

    if song.destroy
      flash.notice = t('.success')
      redirect_to songs_path
    else
      flash.alert = t('.error')
      render :edit, status: :unprocessable_content
    end
  end

  private

  def song_params
    params.expect(song: [:title, :composer, :arranger, :lyrics, :key_signature, :time_signature, :language,
                         :repertoire, :genres, { registers: [] }])
          .tap { |p| p[:registers].reject!(&:blank?) }
          .tap { |p| p[:genres] = p[:genres].split(',').map(&:strip).compact_blank.uniq }
  end
end
