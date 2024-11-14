# frozen_string_literal: true

class NameGuessesController < ApplicationController
  def new
    random_user_with_picture = User.active.joins(:picture_attachment).sample
    @name_guess = authorize NameGuess.new(guessee: random_user_with_picture)
  end

  def create
    guess = authorize NameGuess.new(name_guess_params.merge(guesser: current_user))

    guess.save!
    set_flash(guess)

    redirect_to new_name_guess_path
  end

  private

  def set_flash(guess) # rubocop:disable Naming/AccessorMethodName
    if guess.correct?
      flash.notice = t('name_guesses.create.correct_guess')
    else
      flash.alert = t('name_guesses.create.wrong_guess', name: name_for_flash(guess))
    end
  end

  def name_for_flash(guess)
    name = guess.guessee.first_name
    name += " (#{guess.guessee.nick_name})" if guess.guessee.nick_name.present?
    name
  end

  def name_guess_params
    params.require(:name_guess).permit(:guessee_id, :guess)
  end
end
