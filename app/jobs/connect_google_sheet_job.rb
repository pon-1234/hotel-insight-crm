# frozen_string_literal: true

require 'jwt'

class ConnectGoogleSheetJob < ApplicationJob
  queue_as :default

  def perform(survey_id)
    @survey = Survey.find_by_id(survey_id)
    return if @survey.nil? || @survey.connected_to_ggsheet?

    result = GoogleApi::GetServiceTokens.new.perform(@survey.google_oauth_code)
    @survey.google_oauth_tokens = result
    create_spreadsheet_and_sync
    update_google_oauth_email
    update_google_oauth_for_related_surveys

    @survey.connected_to_ggsheet = true
    @survey.save!
  end

  def create_spreadsheet_and_sync
    sheets = Google::Apis::SheetsV4::SheetsService.new
    sheets.authorization = @survey.google_oauth_access_token
    spreadsheet = {
      properties: {
        title: @survey.name
      }
    }
    spreadsheet = sheets.create_spreadsheet(spreadsheet,
                                            fields: 'spreadsheetId')
    @survey.spreadsheet_id = spreadsheet.spreadsheet_id

    # Add sheet header
    question_titles = @survey.survey_questions.pluck('content').pluck('text')
    values = [
      [
        '回答ID',
        '回答日時',
        '回答者ID',
        '回答者名'
      ] + question_titles
    ]
    value_range = Google::Apis::SheetsV4::ValueRange.new(values: values)
    sheets.append_spreadsheet_value(@survey.spreadsheet_id,
                                              "A1:A#{4 + question_titles.size}",
                                              value_range,
                                              value_input_option: 'RAW')
    SyncAllResponseToGoogleSheetJob.perform_now(@survey.id)
  end

  def update_google_oauth_email
    basic_info = JWT.decode @survey.google_oauth_tokens['id_token'], nil, false
    @survey.google_oauth_email = basic_info.first['email']
  end

  def update_google_oauth_for_related_surveys
    Survey.where(google_oauth_email: @survey.google_oauth_email).update(google_oauth_tokens: @survey.google_oauth_tokens)
  end
end
