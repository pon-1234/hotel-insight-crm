# frozen_string_literal: true

class CreateReservationPrecheckins < ActiveRecord::Migration[6.0]
  def change
    create_table :reservation_precheckins do |t|
      t.references :line_account, foreign_key: true
      t.references :line_friend, foreign_key: true
      t.string :name
      t.string :phone_number
      t.date :check_in_date
      t.string :address
      t.string :birthday
      t.string :companion
      t.integer :gender

      t.timestamps
    end
  end
end
