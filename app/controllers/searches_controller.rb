# frozen_string_literal: true

class SearchesController < ApplicationController
  def show
    query = params[:search][:query]

    @songs = authorize Song.where('title LIKE ?', "%#{query}%")
  end
end
