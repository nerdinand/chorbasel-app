# frozen_string_literal: true

class UsersController < ApplicationController
  ALLOWED_ORDER_COLUMNS = %w[register first_name].freeze

  def index
    order = params[:order] || 'first_name'

    unless order.in? ALLOWED_ORDER_COLUMNS
      render file: 'public/400.html', status: :bad_request, layout: false and return
    end

    @users = authorize(order == 'register' ? User.ordered_by_register : User.order(order))

    respond_to do |format|
      format.html
      format.xlsx { render xlsx: @users }
    end
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
      flash.notice = t('.success')
      redirect_to users_path
    else
      flash.alert = t('.error')
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @user = authorize User.find(params[:id])

    if @user.update(user_params)
      flash.notice = t('.success')
      redirect_to update_success_redirect_path
    else
      flash.alert = t('.error')
      render :edit, status: :unprocessable_entity
    end
  end

  private

  # TODO: solve this with https://github.com/varvet/pundit?tab=readme-ov-file#strong-parameters
  def user_params
    if policy(:user).admin_edit?
      admin_user_params.tap { |p| p[:roles].reject!(&:blank?) }
    else
      regular_user_params
    end
  end

  def admin_user_params
    params.expect(user: [:email, :first_name, :last_name, :nick_name, :salutation, :street, :zip_code, :city,
                         :phone_number, :birth_date, :register, :face_picture, :profile_picture, :status,
                         :member_since, :remarks, { roles: [] }])
  end

  def regular_user_params
    params.expect(user: %i[email first_name last_name nick_name salutation street zip_code city
                           phone_number birth_date register face_picture profile_picture])
  end

  def update_success_redirect_path
    if policy(:user).index?
      users_path
    else
      dashboard_path
    end
  end
end
