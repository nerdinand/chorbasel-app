# frozen_string_literal: true

Rails.logger = Logger.new($stdout)
Rails.logger.level = Logger::INFO

Faker::Config.locale = :en
Faker::Config.random = Random.new(42)

Rails.logger.info 'Creating users...'

User.create!(
  first_name: 'Ferdinand',
  last_name: 'Niedermann',
  nick_name: 'Ferdi',
  email: 'nerdinand@nerdinand.com',
  roles: [Roles::ROLE_APP],
  register: Register::Singer::REGISTER_BASS_2,
  phone_number: '+41791234567'
)

User.create!(
  first_name: 'Hana',
  last_name: 'Harencarova',
  nick_name: 'Hanka',
  email: 'h@seionline.ch',
  roles: [Roles::ROLE_APP],
  register: Register::Singer::REGISTER_ALTO_1,
  phone_number: '+41791234567'
)

User.create!(
  first_name: 'Fabienne',
  last_name: 'Holzer',
  email: 'fabienne@chorbasel.ch',
  roles: [Roles::ROLE_ABSENCES],
  register: Register::Singer::REGISTER_ALTO_2,
  phone_number: '+41791234567'
)

30.times do
  first_name = Faker::Name.first_name
  last_name = Faker::Name.last_name
  nick_name = (Faker::Adjective.positive if Faker::Boolean.boolean)
  roles = if Faker::Boolean.boolean(true_ratio: 0.3) # rubocop:disable Rails/ThreeStateBooleanColumn
            [Roles::ROLES.sample]
          else
            []
          end
  register = Register::Singer::REGISTERS.sample
  phone_number = Faker::PhoneNumber.cell_phone_in_e164

  User.create!(
    first_name:,
    last_name:,
    nick_name:,
    email: Faker::Internet.email(name: "#{first_name} #{last_name}", domain: 'example.com'),
    roles:,
    register:,
    phone_number:
  )
end

Rails.logger.info 'Creating calendar events...'

start_date = Time.zone.local(2024, 1, 4)
end_date = start_date + 1.year

first_start_time_epoch = start_date.change(hour: 20).to_datetime.to_i
last_start_time_epoch = end_date.change(hour: 20).to_datetime.to_i

first_end_time_epoch = start_date.change(hour: 22).to_datetime.to_i
last_end_time_epoch = end_date.change(hour: 22).to_datetime.to_i

(first_start_time_epoch..last_start_time_epoch).step(1.week).zip(
  (first_end_time_epoch..last_end_time_epoch).step(1.week)
) do |times|
  CalendarEvent.create!(
    uid: Faker::Internet.uuid,
    summary: 'ChorBasel: normale Probe',
    event_created_at: Time.zone.now,
    starts_at: Time.zone.at(times[0]),
    ends_at: Time.zone.at(times[1]),
    location: 'Sekundarschule De Wette, De Wette-Strasse 7, 4051 Basel, Switzerland'
  )
end

Rails.logger.info 'Creating attendances...'

users = User.all.to_a
calendar_events = CalendarEvent.all.to_a

1000.times do
  user = users.sample
  calendar_event = calendar_events.sample
  attendance = Attendance.find_or_initialize_by(user:, calendar_event:)
  next unless attendance.new_record?

  attendance.status = Attendance::STATUSES.sample
  attendance.remarks = Faker::Lorem.sentence
  attendance.save!
end
