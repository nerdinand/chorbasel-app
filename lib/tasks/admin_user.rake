# frozen_string_literal: true

namespace :admin_user do
  desc 'Creates a new admin user, can be used to set up the project locally.'
  task create: :environment do
    user = User.create!(email: 'your-email@example.com', first_name: 'Your first name', last_name: 'Your last name',
                        roles: ['app'])
    UserStatus.create!(status: 'active', from_date: Time.zone.today, user:)
  end
end
