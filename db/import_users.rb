# frozen_string_literal: true

require 'csv'

Rails.logger = Logger.new($stdout)
Rails.logger.level = Logger::INFO

csv = CSV.read('220812_ChorBasel_Mitgliederliste_22_23 - Aktive.csv', headers: true)

REGISTER_MAPPING = {
  nil => nil,
  'S1' => 'soprano_1',
  'S2' => 'soprano_2',
  'A1' => 'alto_1',
  'A2' => 'alto_2',
  'T1' => 'tenor_1',
  'T2' => 'tenor_2',
  'B1' => 'bass_1',
  'B2' => 'bass_2'
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
  attributes = {
    salutation: row['Anrede'],
    last_name: row['Name'],
    first_name: row['Vorname'],
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
