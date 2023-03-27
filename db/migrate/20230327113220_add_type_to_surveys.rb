# frozen_string_literal: true

class AddTypeToSurveys < ActiveRecord::Migration[6.0]
  def change
    add_column :surveys, :type, :string, after: :folder_id, default: 'normal'
  end
end
