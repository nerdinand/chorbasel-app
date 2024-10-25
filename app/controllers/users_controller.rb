# frozen_string_literal: true

class UsersController < ApplicationController
  def index
    @users = authorize User.order(:nick_name, :first_name)
  end

  def new
    @user = authorize User.new
  end

  def edit
    @user = authorize User.find(params[:id])
  end

  def create
    @user = authorize User.new(user_params)

    if @user.save
      UserMailer.with(user: @user).welcome_email.deliver_later
      flash[:success] = t('.success')
      redirect_to users_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @user = authorize User.find(params[:id])

    if @user.update(user_params)
      flash[:success] = t('.success')
      redirect_to update_success_redirect_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    if policy(:user).admin_edit?
      admin_user_params.tap { |p| p[:roles].reject!(&:blank?) }
    else
      regular_user_params
    end
  end

  def admin_user_params
    params.require(:user).permit(:email, :first_name, :last_name, :nick_name, :salutation, :street, :zip_code, :city,
                                 :phone_number, :birth_date, :register, :status, :member_since,
                                 :remarks, roles: [])
  end

  def regular_user_params
    params.require(:user).permit(:email, :first_name, :last_name, :nick_name, :salutation, :street, :zip_code, :city,
                                 :phone_number, :birth_date, :register)
  end

  def update_success_redirect_path
    if policy(:user).index?
      users_path
    else
      dashboard_path
    end
  end
end
