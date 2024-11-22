# frozen_string_literal: true

class Feedback
  include ActiveModel::Model

  attr_accessor :message, :anonymous, :user_id

  validates :message, presence: true
  validates :anonymous, presence: true
  validates :user_id, presence: true

  def user
    User.find(user_id)
  end

  def user_name
    if anonymous == '1'
      'Anonymous'
    else
      user.full_name
    end
  end
end
