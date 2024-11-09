# frozen_string_literal: true

class SongsController < ApplicationController
  def index
    @songs = authorize Song.all
  end

  def new
    @song = authorize Song.new(
      registers: Register::Song::DEFAULT_REGISTERS
    )
  end

  def edit
    @song = authorize Song.find(params[:id])
  end

  def create
    @song = authorize Song.new(song_params)

    if @song.save
      flash[:success] = t('.success')
      redirect_to songs_path
    else
      flash[:error] = t('.error')
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @song = authorize Song.find(params[:id])

    if @song.update(song_params)
      flash[:success] = t('.success')
      redirect_to songs_path
    else
      flash[:error] = t('.error')
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    song = authorize Song.find(params[:id])

    if song.destroy
      flash[:success] = t('.success')
      redirect_to songs_path
    else
      flash[:error] = t('.error')
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def song_params
    params.require(:song).permit(:title, :composer, :arranger, :lyrics, :key_signature, :time_signature, :language,
                                 :repertoire, :genres, registers: [])
          .tap { |p| p[:registers].reject!(&:blank?) }
          .tap { |p| p[:genres] = p[:genres].split(',').map(&:strip).uniq }
  end
end
