# frozen_string_literal: true

class ProfilesController < ApplicationController
  def index
    @users = User.active.joins(:profile_picture_attachment).order(:first_name)
  end
end
