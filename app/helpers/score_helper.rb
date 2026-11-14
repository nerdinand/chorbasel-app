# frozen_string_literal: true

module ScoreHelper
  def trackswitch_config(song_id, recordings)
    {
      css: {},
      media: recording_map(recordings).to_h do |id, hash|
        [id, { type: 'audio', src: hash[:src], title: hash[:title] }]
      end,
      views: views_config(recordings.pluck(:id).map(&:to_s)),
      markers: markers_config(song_id)
    }
  end

  private

  def views_config(recording_ids)
    [
      {
        type: 'navigationBar',
        controls: %w[playback globalVolume markerNavigation looping markerEditing timer]
      },
      { type: 'waveform', height: 50, tracks: 'audible', markerLayers: [{ sequence: 'markers' }] },
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

  def markers_config(song_id)
    {
      markers: {
        type: 'segments',
        timeCol: 'time',
        labelCol: 'label',
        src: song_markers_path(song_id, format: 'csv')
      }
    }
  end
end
