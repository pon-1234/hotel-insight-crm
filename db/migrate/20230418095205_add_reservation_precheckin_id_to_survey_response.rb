class AddReservationPrecheckinIdToSurveyResponse < ActiveRecord::Migration[6.0]
  def change
    add_reference :survey_responses, :reservation_precheckin, index: true
    add_foreign_key :survey_responses, :reservation_precheckins
  end
end
