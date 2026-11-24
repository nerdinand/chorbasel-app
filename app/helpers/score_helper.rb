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

  # The site palette (application.tailwind.css) for the player, so it follows light and dark mode
  PLAYER_CSS = {
    '--ts-font-ui': '"Inter var", ui-sans-serif, system-ui, sans-serif',
    '--ts-color-text-primary': 'rgb(var(--color-ink))',
    '--ts-color-text-secondary': 'rgb(var(--color-muted))',
    '--ts-color-text-muted': 'rgb(var(--color-on-primary) / 0.8)', # control bar icons and every other track row
    '--ts-color-surface-base': 'rgb(var(--color-contrast))',
    '--ts-color-surface-raised-72': 'rgb(var(--color-bg) / 0.72)', # section labels on the waveform
    '--ts-color-surface-raised-94': 'rgb(var(--color-bg) / 0.94)', # marker labels when editing
    '--ts-color-surface-panel-dark': 'rgb(var(--color-primary))', # control bar
    '--ts-color-surface-panel-dark-16': 'rgb(var(--color-primary) / 0.25)', # selected track row
    '--ts-color-surface-control': 'rgb(255 255 255 / 0.35)', # slider tracks in the control bar
    '--ts-color-border-mid': 'rgb(var(--color-line))',
    '--ts-color-accent': 'rgb(var(--color-complementary))',
    '--ts-focus-ring-color': 'rgb(var(--color-primary-dark))'
  }.freeze

  def trackswitch_config(song)
    recordings = song.song_media.recording.ordered_by_register

    {
      css: PLAYER_CSS,
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
