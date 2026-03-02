# frozen_string_literal: true

class DropAraskJobs < ActiveRecord::Migration[8.1]
  def up
    drop_table :arask_jobs
  end
end
