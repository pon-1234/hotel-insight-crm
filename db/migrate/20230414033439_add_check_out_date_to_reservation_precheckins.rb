class AddCheckOutDateToReservationPrecheckins < ActiveRecord::Migration[6.0]
  def change
    add_column :reservation_precheckins, :check_out_date, :date, after: :check_in_date
  end
end
