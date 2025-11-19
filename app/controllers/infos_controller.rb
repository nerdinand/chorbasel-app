# frozen_string_literal: true

class InfosController < ApplicationController
  def index
    @infos = authorize Info.newest
  end

  def new
    @info = authorize Info.new(active: true)
  end

  def edit
    @info = authorize Info.find(params[:id])
  end

  def create
    @info = authorize Info.new(info_params)

    if @info.save
      flash.notice = t('.success')
      redirect_to root_path
    else
      flash.alert = t('.error')
      render :new, status: :unprocessable_content
    end
  end

  def update
    @info = authorize Info.find(params[:id])

    if @info.update(info_params)
      flash.notice = t('.success')
      redirect_to root_path
    else
      flash.alert = t('.error')
      render :new, status: :unprocessable_content
    end
  end

  private

  def info_params
    params.expect(info: %i[title description kind active])
  end
end
