# frozen_string_literal: true

require 'csv'

FIRST_NAME_REGEX = /\A(?<first_name>.+?)(?: \((?<nick_name>.+)\))?\z/

Rails.logger = Logger.new($stdout)
Rails.logger.level = Logger::INFO

csv = CSV.read('storage/users.csv', headers: true)

REGISTER_MAPPING = {
  nil => nil,
  'S1' => Register::Singer::REGISTER_SOPRANO_1,
  'S2' => Register::Singer::REGISTER_SOPRANO_2,
  'A1' => Register::Singer::REGISTER_ALTO_1,
  'A2' => Register::Singer::REGISTER_ALTO_2,
  'T1' => Register::Singer::REGISTER_TENOR_1,
  'T2' => Register::Singer::REGISTER_TENOR_2,
  'B1' => Register::Singer::REGISTER_BASS_1,
  'B2' => Register::Singer::REGISTER_BASS_2
}.freeze

def map_register(register)
  if REGISTER_MAPPING.key? register
    REGISTER_MAPPING[register]
  else
    Rails.logger.error("Invalid register value: #{register.inspect}")
    nil
  end
end

csv.each do |row|
  first_name_match = row['Vorname'].match(FIRST_NAME_REGEX)

  attributes = {
    salutation: row['Anrede'],
    last_name: row['Name'],
    first_name: first_name_match[:first_name],
    nick_name: first_name_match[:nick_name],
    street: row['Strasse'],
    zip_code: row['PLZ'],
    city: row['Ort'],
    phone_number: row['Tel_M']&.gsub(/[^\+\d]/, '').presence,
    email: row['EMail'],
    birth_date: row['Geburtstag'],
    status: :active,
    member_since: row['Mitglied seit'],
    register: map_register(row['Stimme']),
    remarks: row['Bemerkung']
  }

  user = User.new(attributes)

  if user.save
    Rails.logger.info("Created user #{user.full_name}")
  else
    Rails.logger.error("Failed to create user with attributes #{attributes}: #{user.errors.messages}")
  end
end
