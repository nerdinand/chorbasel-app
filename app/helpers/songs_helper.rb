# frozen_string_literal: true

module SongsHelper
  def register_string(registers)
    return 'SATB' if registers == Register::Song::DEFAULT_REGISTERS

    # i18n-tasks-use t('activerecord.attributes.song.enums.register')
    registers.map { |r| t("activerecord.attributes.song.enums.register.#{r}") }.join(', ')
  end

  def trackswitch_config(recordings)
    {
      css: {},
      media: recording_map(recordings).to_h do |id, hash|
        [id, { type: 'audio', src: hash[:src], title: hash[:title] }]
      end,
      views: views_config(recordings.pluck(:id).map(&:to_s))
    }
  end

  private

  def views_config(recording_ids)
    [
      {
        type: 'navigationBar',
        controls: %w[playback globalVolume markerNavigation looping sync timer seekBar]
      },
      *recording_ids.map do |id|
        { type: 'waveform', height: 50, tracks: [id] }
      end,
      { type: 'trackList', tracks: recording_ids }
    ]
  end

  def recording_map(recordings)
    recordings.to_h do |recording|
      title = if recording.register.present?
                human_register(recording.register)
              else
                I18n.t('songs.score.all_registers')
              end

      [recording.id.to_s, { src: recording.file_url, title: }]
    end
  end
end
