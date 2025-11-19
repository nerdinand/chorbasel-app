# frozen_string_literal: true

class FeedbacksController < ApplicationController
  def new
    @feedback = Feedback.new
  end

  def create
    @feedback = Feedback.new(feedback_params)

    if @feedback.valid?
      FeedbackMailer.with(feedback: feedback_params).feedback_email.deliver_later
      flash.notice = t('.success')
      redirect_to root_path
    else
      flash.alert = t('.error')
      render :new, status: :unprocessable_content
    end
  end

  private

  def feedback_params
    params.expect(feedback: %i[message anonymous]).merge(user_id: current_user.id)
  end
end
