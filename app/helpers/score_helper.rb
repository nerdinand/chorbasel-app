# frozen_string_literal: true

module ScoreHelper
  ADMIN_CONTROLS = %w[markerEditing].freeze

  SEGMENTS_WAVEFORM = {
    type: 'waveform', height: 50, tracks: 'audible',
    markerLayers: [{ sequence: 'segments' }]
  }.freeze

  MEASURES_WAVEFORM = {
    type: 'waveform', height: 50, tracks: 'audible',
    markerLayers: [{ sequence: 'measures', color: '#777' }]
  }.freeze

  def trackswitch_config(song)
    recordings = song.song_media.recording.ordered_by_register
    {
      css: {},
      media: recording_map(recordings).to_h do |id, hash|
        [id, { type: 'audio', src: hash[:src], title: hash[:title] }]
      end,
      views: views_config(song, recordings.pluck(:id).map(&:to_s)),
      markers: markers_config(song.id)
    }
  end

  private

  def views_config(song, recording_ids)
    admin_mode = policy(song.score).edit?

    [
      {
        type: 'navigationBar',
        controls: %w[playback globalVolume markerNavigation looping timer] +
          (admin_mode ? ADMIN_CONTROLS : [])
      }
    ] + waveform_config(admin_mode) + [{ type: 'trackList', tracks: recording_ids }]
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

  def waveform_config(admin_mode)
    [SEGMENTS_WAVEFORM] + (admin_mode ? [MEASURES_WAVEFORM] : [])
  end

  def markers_config(song_id)
    {
      segments: segments_markers_config(song_id),
      measures: measures_markers_config(song_id)
    }
  end

  def segments_markers_config(song_id)
    {
      type: 'segments',
      timeCol: 'time',
      labelCol: 'label',
      src: segment_markers_song_score_path(song_id, format: :csv)
    }
  end

  def measures_markers_config(song_id)
    {
      type: 'points',
      timeCol: 'time',
      labelCol: 'measure',
      src: measure_markers_song_score_path(song_id, format: :csv)
    }
  end
end
