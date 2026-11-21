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
      media: recording_map(recordings),
      views: views_config(song, recordings.pluck(:id).map(&:to_s)),
      markers: markers_config(song.id)
    }
  end

  private

  def views_config(song, recording_ids)
    admin_mode = song.score && policy(song.score).edit?

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
      if recording.register.present?
        recording_entry(recording, human_register(recording.register), false)
      else
        recording_entry(recording, I18n.t('songs.score.all_registers'), true)
      end
    end
  end

  def recording_entry(recording, title, solo)
    [recording.id.to_s, { type: :audio, src: recording.file_url, title:, solo: }]
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
      src: song_score_segment_markers_path(song_id, format: :csv)
    }
  end

  def measures_markers_config(song_id)
    {
      type: 'points',
      timeCol: 'time',
      labelCol: 'measure',
      src: song_score_measure_markers_path(song_id, format: :csv)
    }
  end
end
