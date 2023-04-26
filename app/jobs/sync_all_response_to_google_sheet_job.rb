# frozen_string_literal: true

class SyncAllResponseToGoogleSheetJob < ApplicationJob
  queue_as :default

  def perform(survey_id)
    survey = Survey.find(survey_id)
    return if survey.survey_responses.blank?
    # Init gooogle service
    sheets = Google::Apis::SheetsV4::SheetsService.new
    sheets.authorization = survey.google_oauth_access_token

    values = []
    survey.survey_responses.each do |response|
      answers = response.survey_answers.map { |x| x.norm_answer }
      values << [response.id, response.created_at, response.line_friend_id, response.line_friend_name] + answers
    end
    value_range = Google::Apis::SheetsV4::ValueRange.new(values: values)
    sheets.append_spreadsheet_value(survey.spreadsheet_id,
                                              'A:A',
                                              value_range,
                                              value_input_option: 'RAW')
  end
end
