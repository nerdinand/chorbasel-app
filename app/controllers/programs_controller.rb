# frozen_string_literal: true

class ProgramsController < ApplicationController
  def create
    program = authorize Program.new(program_params)

    if program.save
      flash.notice = t('.success')
    else
      flash.alert = t('.error')
    end
    redirect_to edit_song_list_path(program.song_list)
  end

  def destroy
    program = authorize Program.find(params[:id])

    if program.destroy
      flash.notice = t('.success')
    else
      flash.alert = t('.error')
    end
    redirect_to edit_song_list_path(program.song_list)
  end

  private

  def program_params
    params.expect(program: %i[calendar_event_id song_list_id])
  end
end
