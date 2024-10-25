# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'app@chorbasel.ch'
  layout 'mailer'
end
