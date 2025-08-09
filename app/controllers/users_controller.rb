# frozen_string_literal: true

class UsersController < ApplicationController # rubocop:disable Metrics/ClassLength
  QUERY_PARAM_ORDER = :order
  QUERY_PARAM_FILTER = :filter

  QUERY_PARAMS = [QUERY_PARAM_ORDER, QUERY_PARAM_FILTER].freeze

  QUERY_PARAM_ORDER_REGISTER = 'register'
  QUERY_PARAM_ORDER_FIRST_NAME = 'first_name'
  QUERY_PARAM_ORDER_LAST_NAME = 'last_name'

  QUERY_PARAM_ORDER_VALUES = [QUERY_PARAM_ORDER_REGISTER, QUERY_PARAM_ORDER_FIRST_NAME,
                              QUERY_PARAM_ORDER_LAST_NAME].freeze

  QUERY_PARAM_FILTER_ACTIVE = 'active'
  QUERY_PARAM_FILTER_INACTIVE = 'inactive'
  QUERY_PARAM_FILTER_PAUSED = 'paused'
  QUERY_PARAM_FILTER_ALL = 'all'

  QUERY_PARAM_FILTER_VALUES = [QUERY_PARAM_FILTER_ACTIVE, QUERY_PARAM_FILTER_INACTIVE,
                               QUERY_PARAM_FILTER_PAUSED, QUERY_PARAM_FILTER_ALL].freeze

  def index
    filter = sanitize_filter or (render_bad_request and return)
    order = sanitize_order or (render_bad_request and return)

    users = authorize(apply_filter(filter))
    @users = apply_order(users, order)

    respond_to do |format|
      format.html
      format.xlsx { render xlsx: @users }
    end
  end

  def new
    @user = authorize User.new
  end

  def edit
    @user = authorize User.includes(:user_statuses).find(params[:id])
  end

  def create
    @user = create_user

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

  def sanitize_order
    order = params[QUERY_PARAM_ORDER]

    return QUERY_PARAM_ORDER_FIRST_NAME if order.blank?
    return nil unless order.in? QUERY_PARAM_ORDER_VALUES

    order
  end

  def sanitize_filter
    filter = params[QUERY_PARAM_FILTER]

    return QUERY_PARAM_FILTER_ACTIVE if filter.blank?
    return nil unless filter.in? QUERY_PARAM_FILTER_VALUES

    filter
  end

  def apply_filter(filter)
    if filter == QUERY_PARAM_FILTER_ALL
      User.all
    else
      User.user_status_now(filter)
    end
  end

  def apply_order(users, order)
    order == QUERY_PARAM_ORDER_REGISTER ? users.ordered_by_register : users.order("#{order} COLLATE NOCASE")
  end

  def render_bad_request
    render file: 'public/400.html', status: :bad_request, layout: false
  end

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

  def create_user
    authorize User.new(
      user_params.merge(
        user_statuses_attributes: [
          { status: UserStatus::STATUS_ACTIVE,
            from_date: Time.zone.today }
        ]
      )
    )
  end
end
