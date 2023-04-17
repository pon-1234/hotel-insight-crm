class RenameBirthdayOnReservationPrecheckin < ActiveRecord::Migration[6.0]
  def change
    rename_column :reservation_precheckins, :birthday, :birthdate
  end
end
