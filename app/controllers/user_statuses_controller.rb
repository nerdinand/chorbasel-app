# frozen_string_literal: true

class UserStatusesController < ApplicationController
  def new
    @user_status = authorize UserStatus.new(user_id: params[:user_id])
  end

  def edit
    @user_status = authorize UserStatus.find(params[:id])
  end

  def create
    @user_status = authorize UserStatus.new(user_status_params)

    if @user_status.save
      flash.notice = t('.success')
      redirect_to edit_user_path(@user_status.user)
    else
      flash.alert = t('.error')
      render :new, status: :unprocessable_content
    end
  end

  def update
    @user_status = authorize UserStatus.find(params[:id])

    if @user_status.update(user_status_params)
      flash.notice = t('.success')
      redirect_to edit_user_path(@user_status.user)
    else
      flash.alert = t('.error')
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    user_status = authorize UserStatus.find(params[:id])

    if user_status.destroy
      flash.notice = t('.success')
    else
      flash.alert = t('.error')
    end

    redirect_to edit_user_path(user_status.user)
  end

  private

  def user_status_params
    params.expect(user_status: %i[user_id status from_date to_date note])
  end
end
