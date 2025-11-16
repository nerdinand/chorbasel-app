# frozen_string_literal: true

class FeedbackMailer < ApplicationMailer
  def feedback_email
    @feedback = Feedback.new(params[:feedback])
    mail(mail_params)
  end

  private

  def mail_params
    params = { to: 'app@chorbasel.ch', subject: t('feedback_mailer.subject') }
    params[:from] = @feedback.user_email if @feedback.user_email.present?
    params
  end
end
