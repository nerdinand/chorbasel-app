# frozen_string_literal: true

class SongsController < ApplicationController
  def index
    songs = Song.order(:title)
    @songs = if params[:language].present?
               authorize songs.where(language: params[:language])
             else
               authorize songs.all
             end
  end

  def show
    @song = authorize Song.includes(:song_media).find(params.expect(:id))

    recording_map = @song.song_media.recording.ordered_by_register.to_h do |recording|
      src = if recording.file.present?
              url_for(recording.file)
            else
              song_song_medium_load_path(song_id: recording.song.id, song_medium_id: recording.id)
            end

      title = if recording.register.present?
                human_register(recording.register)
              else
                t('.all_registers')
              end
      [recording.id.to_s, { src:, title: }]
    end

    @score_config = {
      css: {},
      media: recording_map.to_h do |id, hash|
        [id, { type: 'audio', src: hash[:src], title: hash[:title] }]
      end,
      views: [
        {
          type: 'navigationBar',
          controls: %w[playback globalVolume markerNavigation looping sync timer seekBar]
        },
        *recording_map.keys.map do |id|
          { type: 'waveform', height: 50, tracks: [id] }
        end,
        { type: 'trackList', tracks: recording_map.keys }
      ]
    }
  end

  def new
    @song = authorize Song.new(
      registers: Register::Song::DEFAULT_REGISTERS
    )
  end

  def edit
    @song = authorize Song.find(params.expect(:id))
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
    @song = authorize Song.find(params.expect(:id))

    if @song.update(song_params)
      flash.notice = t('.success')
      redirect_to songs_path
    else
      flash.alert = t('.error')
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    song = authorize Song.find(params.expect(:id))

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
    params.expect(song: [:title, :music_composer, :texter, :arranger, :lyrics, :key_signature, :time_signature,
                         :language, :repertoire, :genres, { registers: [] }])
          .tap { |p| p[:registers].reject!(&:blank?) }
          .tap { |p| p[:genres] = p[:genres].split(',').map(&:strip).compact_blank.uniq }
  end
end
