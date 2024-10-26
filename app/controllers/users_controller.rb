# frozen_string_literal: true

class UsersController < ApplicationController
  def index
    @users = authorize User.all
  end

  def new
    @user = authorize User.new
  end

  def edit
    @user = authorize User.find(params[:id])
  end

  def create
    @user = authorize(User.new(user_params))

    if @user.save
      UserMailer.with(user: @user).welcome_email.deliver_later
      flash[:success] = t('.success')
      redirect_to users_path
    else
      flash[:error] = t('.error')
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @user = authorize User.find(params[:id])

    if @user.update(user_params)
      flash[:success] = t('.success')
      redirect_to users_path
    else
      flash[:error] = t('.error')
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :first_name, :last_name, :nick_name)
  end
end
