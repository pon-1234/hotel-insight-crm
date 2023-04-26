# frozen_string_literal: true

class SyncResponseToGoogleSheetJob < ApplicationJob
  queue_as :default

  def perform(response_id)
    response = SurveyResponse.find(response_id)
    survey = response.survey
    # Init gooogle service
    sheets = Google::Apis::SheetsV4::SheetsService.new

    # Get access token
    sheets.authorization = survey.google_oauth_access_token

    answers = response.survey_answers.map { |x| x.norm_answer }
    data = [response.id, response.created_at, response.line_friend_id, response.line_friend_name] + answers
    values = [
      data
    ]
    value_range = Google::Apis::SheetsV4::ValueRange.new(values: values)
    sheets.append_spreadsheet_value(survey.spreadsheet_id,
                                              'A:A',
                                              value_range,
                                              value_input_option: 'RAW')
  end
end
