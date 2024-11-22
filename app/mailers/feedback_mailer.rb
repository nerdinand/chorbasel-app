# frozen_string_literal: true

class FeedbackMailer < ApplicationMailer
  def feedback_email
    @feedback = Feedback.new(params[:feedback])
    mail(to: 'app@chorbasel.ch', subject: t('.subject'))
  end
end
