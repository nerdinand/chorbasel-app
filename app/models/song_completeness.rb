# frozen_string_literal: true

class SongCompleteness # rubocop:disable Metrics/ClassLength
  def initialize(song)
    @song = song
  end

  def self.build_list(songs)
    songs.map { |song| SongCompleteness.new(song) }
  end

  def basics_complete?
    basics.values.all?
  end

  def missing_basics
    basics.reject { |_k, v| v }.keys
  end

  def basics # rubocop:disable Metrics/MethodLength
    @basics ||= {
      music_composer: music_composer_present?,
      arranger: arranger_present?,
      texter: texter_present?,
      key_signature: key_signature_present?,
      time_signature: time_signature_present?,
      language: language_present?,
      registers: registers_present?,
      genres: genres_present?,
      lyrics: lyrics_present?
    }
  end

  def song_media_complete?
    song_media.values.all?
  end

  def missing_song_media_registers
    song_media_registers.reject { |_k, v| v }.keys
  end

  def song_media
    song_media_registers
      .merge({ sheet_music: song_media_sheet_music_present? })
      .merge({ recording_all: song_media_recording_all_present? })
  end

  def song_media_sheet_music_present?
    @song_media_sheet_music_present ||= song.song_media.sheet_music.present?
  end

  def song_media_recording_all_present?
    @song_media_recording_all_present ||= song.song_media.recording_all.present?
  end

  def song_media_registers
    @song_media_registers ||= song.registers.index_with do |register|
      song.song_media.recording.where(register:).present?
    end
  end

  def score_complete?
    score.values.all?
  end

  def missing_score
    score.reject { |_k, v| v }.keys
  end

  def score
    { file: score_file_present? }
      .merge({ segment_markers: score_segment_markers_present? })
      .merge({ measure_markers: score_measure_markers_present? })
  end

  def score_file_present?
    song.score&.file&.present?
  end

  def score_segment_markers_present?
    return false unless (segment_markers = song.score&.segment_markers)
    return false unless (second_line = segment_markers&.lines&.second)

    second_line.present?
  end

  def score_measure_markers_present?
    return false unless (measure_markers = song.score&.measure_markers)
    return false unless (second_line = measure_markers&.lines&.second)

    second_line.present?
  end

  attr_reader :song

  delegate :title, to: :song

  private

  def music_composer_present?
    song.music_composer.present?
  end

  def arranger_present?
    song.arranger.present?
  end

  def texter_present?
    song.texter.present?
  end

  def key_signature_present?
    song.key_signature.present?
  end

  def time_signature_present?
    song.time_signature.present?
  end

  def language_present?
    song.language.present?
  end

  def registers_present?
    song.registers.any?
  end

  def genres_present?
    song.genres.any?
  end

  def lyrics_present?
    song.lyrics.present?
  end
end
