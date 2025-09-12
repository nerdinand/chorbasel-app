# frozen_string_literal: true

class SearchesController < ApplicationController
  def show
    query = params[:search][:query]

    @songs = Song.where('title LIKE ?', "%#{query}%")
  end
end
