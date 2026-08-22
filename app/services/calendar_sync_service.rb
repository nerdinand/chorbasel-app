# frozen_string_literal: true

class CalendarSyncService
  def initialize(calendar_url)
    @calendar_url = calendar_url
    @calendar_tmp_path = Rails.root.join('tmp/calendar.ics')
  end

  def perform!
    download_file(calendar_url, calendar_tmp_path)
    events = parse_ics(calendar_tmp_path)
    CalendarSyncDatabaseService.new.perform!(events)
  end

  private

  attr_reader :calendar_url, :calendar_tmp_path

  def download_file(url, file_path)
    Rails.logger.info 'Downloading calendar file...'
    Down.download(url, destination: file_path)
    Rails.logger.info 'Finished downloading calendar file.'
  end

  def parse_ics(file_path)
    Rails.logger.info 'Parsing calendar file...'
    ics_content = File.read(file_path)
    events = OccurrenceResolver.parse_and_resolve(ics_content)
    Rails.logger.info 'Finished parsing calendar file.'
    events
  end
end
