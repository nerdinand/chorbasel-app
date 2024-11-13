# frozen_string_literal: true

class CreateNameGuesses < ActiveRecord::Migration[8.0]
  def change
    create_table :name_guesses do |t|
      t.references :guesser, foreign_key: { to_table: :users }
      t.references :guessee, foreign_key: { to_table: :users }
      t.boolean :correct, null: false, default: false

      t.timestamps
    end
  end
end
